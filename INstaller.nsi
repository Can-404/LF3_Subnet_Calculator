!include "MUI2.nsh"

Name "Subnet Calculator"
OutFile "Subnet Calculator 1.0.0 Installer.exe"
InstallDir "$APPDATA\Subnet Calculator"
Icon "Icon256x256.ico"

!define AppName "Subnet Calculator"
!define AppVersion "1.0.0"
!define Publisher "T5"
!define UninstallRegKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${AppName}"

; Define installer pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM

Section "MainSection"
    SetOutPath "$INSTDIR"
    File "SubnetCalculator.exe"
    File "netz.exe"
    File "Icon256x256.ico"
    File "ips.json"
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Create a desktop shortcut
    CreateShortCut "$DESKTOP\Subnet Calculator.lnk" "$INSTDIR\SubnetCalculator.exe" "" "$INSTDIR\Icon256x256.ico" 0

    ; Add registry entries for "Apps & features"
    WriteRegStr HKCU "${UninstallRegKey}" "DisplayName" "${AppName}"
    WriteRegStr HKCU "${UninstallRegKey}" "DisplayVersion" "${AppVersion}"
    WriteRegStr HKCU "${UninstallRegKey}" "Publisher" "${Publisher}"
    WriteRegStr HKCU "${UninstallRegKey}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKCU "${UninstallRegKey}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKCU "${UninstallRegKey}" "DisplayIcon" "$INSTDIR\Icon256x256.ico"
SectionEnd

Section "Uninstall"
    ; Remove application files
    Delete "$INSTDIR\SubnetCalculator.exe"
    Delete "$INSTDIR\netz.exe"
    Delete "$INSTDIR\Icon256x256.ico"
    Delete "$INSTDIR\Uninstall.exe"
    Delete "$INSTDIR\ips.json"

    ; Remove desktop shortcut
    Delete "$DESKTOP\Subnet Calculator.lnk"

    ; Remove registry entries
    DeleteRegKey HKCU "${UninstallRegKey}"

    ; Remove directories if empty
    RMDir "$INSTDIR"
SectionEnd
