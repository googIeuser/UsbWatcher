# Inno Setup Installer

USB Watcher uses Inno Setup to create a native Windows installation wizard.

## Installer features

- English-only setup wizard
- Modern native Windows setup appearance
- Installation under `Program Files\USB Watcher`
- Start Menu shortcut
- Optional desktop shortcut
- Uninstaller entry in Windows Settings
- Optional launch when setup finishes
- x64 Windows package

## Build locally

Install Inno Setup, then run from the repository root:

```powershell
.\scripts\build-windows.ps1 -Version 0.1.0
```

Or double-click:

```text
BUILD_RELEASE.cmd
```

The build creates:

```text
artifacts/USB_Watcher_Setup_0.1.0.exe
artifacts/USB-Watcher-v0.1.0-win-x64.zip
artifacts/SHA256SUMS.txt
```

The installer script is `installer/USBWatcher.iss`.
