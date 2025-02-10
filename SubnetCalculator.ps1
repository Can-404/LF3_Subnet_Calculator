Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define JSON file path
$jsonFile = "ips.json"

# GUI Creation
$form = New-Object System.Windows.Forms.Form
$form.Text = "Subnet Calculator"
$form.Size = New-Object System.Drawing.Size(450, 350)
$form.StartPosition = "CenterScreen"

# Set window icon
$iconPath = "C:\Users\Admin\Desktop\Data\VS-Code\LF3_Subnet_Calculator\Icon256x256.ico"  # Change this to your actual icon path
if (Test-Path $iconPath) {
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

# IP Address Label
$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Text = "IP Address:"
$labelIP.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelIP)

# IP Address TextBox
$textBoxIP = New-Object System.Windows.Forms.TextBox
$textBoxIP.Location = New-Object System.Drawing.Point(120, 18)
$form.Controls.Add($textBoxIP)

# Subnet Mask Label
$labelSubnet = New-Object System.Windows.Forms.Label
$labelSubnet.Text = "Subnet Mask:"
$labelSubnet.Location = New-Object System.Drawing.Point(10, 50)
$form.Controls.Add($labelSubnet)

# Subnet Mask TextBox
$textBoxSubnet = New-Object System.Windows.Forms.TextBox
$textBoxSubnet.Location = New-Object System.Drawing.Point(120, 48)
$form.Controls.Add($textBoxSubnet)

# Calculate Button
$buttonCalculate = New-Object System.Windows.Forms.Button
$buttonCalculate.Text = "Calculate"
$buttonCalculate.Location = New-Object System.Drawing.Point(120, 80)
$form.Controls.Add($buttonCalculate)

# Result Label
$labelResult = New-Object System.Windows.Forms.Label
$labelResult.Location = New-Object System.Drawing.Point(10, 110)
$labelResult.Size = New-Object System.Drawing.Size(360, 180)
$form.Controls.Add($labelResult)

# Validate IP address and Subnet Mask
function Validate-IPSubnet {
    param (
        [string]$ip,
        [string]$subnet
    )

    # IP validation regex (ensures each octet is 0-255)
    $ipPattern = "^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}$"

    # Valid subnet masks
    $validSubnets = @(
        "128.0.0.0", "192.0.0.0", "224.0.0.0", "240.0.0.0",
        "248.0.0.0", "252.0.0.0", "254.0.0.0", "255.0.0.0",
        "255.128.0.0", "255.192.0.0", "255.224.0.0", "255.240.0.0",
        "255.248.0.0", "255.252.0.0", "255.254.0.0", "255.255.0.0",
        "255.255.128.0", "255.255.192.0", "255.255.224.0", "255.255.240.0",
        "255.255.248.0", "255.255.252.0", "255.255.254.0", "255.255.255.0",
        "255.255.255.128", "255.255.255.192", "255.255.255.224",
        "255.255.255.240", "255.255.255.248", "255.255.255.252",
        "255.255.255.254", "255.255.255.255"
    )

    return ($ip -match $ipPattern) -and ($subnet -in $validSubnets)
}

# Button Click Event
$buttonCalculate.Add_Click({
    $ip = $textBoxIP.Text.Trim()
    $subnet = $textBoxSubnet.Text.Trim()

    if (-not (Validate-IPSubnet -ip $ip -subnet $subnet)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid IP Address or Subnet Mask!", "Error", "OK", "Error")
        return
    }

    # Read JSON data if available
    $existingData = @{}
    if (Test-Path $jsonFile) {
        try {
            $existingData = Get-Content $jsonFile | ConvertFrom-Json
        } catch {}
    }

    # Prepare new input data
    $newInputData = @{ 
        Input = @{ 
            IPAddress = $ip
            SubnetMask = $subnet
        }
    }

    # Merge input data only if changed
    if ($existingData.PSObject.Properties.Name -contains 'Input') {
        if ($existingData.Input.IPAddress -ne $ip -or $existingData.Input.SubnetMask -ne $subnet) {
            $existingData.Input = $newInputData.Input
        }
    } else {
        $existingData["Input"] = $newInputData.Input
    }

    # Write updated input data to JSON
    $existingData | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 $jsonFile

    # Start external program for processing
    Start-Process "$PWD\netz.exe" -WindowStyle Hidden

    # Wait for external processing
    Start-Sleep -Milliseconds 100

    # Read output from JSON after processing
    if (Test-Path $jsonFile) {
        $output = Get-Content $jsonFile | ConvertFrom-Json

        if ($output.PSObject.Properties.Name -contains 'Output') {
            # Display results
            $labelResult.Text = @"
Host Count: $($output.Output.HostCount)

Network Address: $($output.Output.NetworkAddress)
Broadcast Address: $($output.Output.BroadcastAddress)


Network Address (Binary): $($output.Output.NetworkBinary)
Broadcast Address (Binary): $($output.Output.BroadcastBinary)

Subnet Mask (Binary): $($output.Output.SubnetMaskBinary)
IP (Binary): $($output.Output.IPBinary)
"@
        }
    }
})

# Show the form
$form.ShowDialog()
