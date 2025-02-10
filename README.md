# NetworkCalculator

## Functions

- Calculates Network Address
- Calculates Broadcast Address
- Shows the Maximal Host Count
- Shows IP, subnet mask, network address and broadcast address in binary

## Poweshell executable

To create a Powershell.exe ps2exe was used with this command:
- Invoke-PS2EXE "$PWD\SubnetCalculator.ps1" "$PWD\SubnetCalculator.exe" -icon "$PWD\Icon256x256.ico" -noConsole

when ps2exe can not load use:
- Set-ExecutionPolicy Bypass -Scope Process -Force
