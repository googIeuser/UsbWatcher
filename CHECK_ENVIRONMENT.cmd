@echo off
setlocal
cd /d "%~dp0"

echo USB Watcher - Development Environment Check
echo ===========================================
echo.

set FAILED=0

where flutter >nul 2>nul
if errorlevel 1 (
  echo [MISSING] Flutter was not found in PATH.
  set FAILED=1
) else (
  echo [OK] Flutter
  flutter --version
)

echo.
where cargo >nul 2>nul
if errorlevel 1 (
  echo [MISSING] Cargo was not found in PATH.
  set FAILED=1
) else (
  echo [OK] Cargo
  cargo --version
)

echo.
where rustc >nul 2>nul
if errorlevel 1 (
  echo [MISSING] Rust compiler was not found in PATH.
  set FAILED=1
) else (
  echo [OK] Rust compiler
  rustc --version
)

echo.
set INNO_FOUND=0
where ISCC.exe >nul 2>nul && set INNO_FOUND=1
if exist "%ProgramFiles%\Inno Setup 7\ISCC.exe" set INNO_FOUND=1
if exist "%ProgramFiles(x86)%\Inno Setup 7\ISCC.exe" set INNO_FOUND=1
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set INNO_FOUND=1
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set INNO_FOUND=1

if "%INNO_FOUND%"=="1" (
  echo [OK] Inno Setup compiler
) else (
  echo [MISSING] Inno Setup compiler - required only for installer builds.
  echo Install command: winget install --id JRSoftware.InnoSetup -e -s winget -i
)

echo.
if "%FAILED%"=="1" (
  echo One or more required development tools are missing.
  echo Read docs\INSTALLATION.md before running the application.
  exit /b 1
)

echo Running Flutter doctor...
flutter doctor -v

echo.
echo Environment check finished.
pause
