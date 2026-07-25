@echo off
setlocal
cd /d "%~dp0"

set VERSION=0.1.0
set /p VERSION=Enter version number [0.1.0]: 
if "%VERSION%"=="" set VERSION=0.1.0

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build-windows.ps1" -Version "%VERSION%"
set EXIT_CODE=%ERRORLEVEL%

echo.
if "%EXIT_CODE%"=="0" (
  echo Build completed successfully.
  echo Open the artifacts folder to find the installer and portable ZIP.
) else (
  echo Build failed with exit code %EXIT_CODE%.
  echo Review docs\INSTALLATION.md and docs\TESTING.md.
)
pause
exit /b %EXIT_CODE%
