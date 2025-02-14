
@echo off
powershell -Command "& {Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-PS2EXE "$PWD\SubnetCalculator.ps1" "$PWD\SubnetCalculator.exe" -icon "$PWD\Icon256x256.ico" -noConsole}"

echo Created Executable

pause
