# Testing

## Core smoke test

```powershell
cargo run --manifest-path .\core\Cargo.toml -- list --pretty
```

The command should print a JSON array. An empty array is valid when no USB devices are visible.

## Flutter analysis and tests

```powershell
cd app
flutter analyze
flutter test
```

## Full development run

```powershell
.\scripts\run-dev.ps1
```

## Full Windows package build

```powershell
.\scripts\build-windows.ps1 -Version 0.1.0
```

Expected artifacts:

```text
artifacts/USB_Watcher_Setup_0.1.0.exe
artifacts/USB-Watcher-v0.1.0-win-x64.zip
artifacts/SHA256SUMS.txt
```

## Installer checklist

- The setup title is `USB Watcher Setup`.
- All setup text is English.
- The USB Watcher icon appears in Setup and the installed application.
- The default installation directory is under Program Files.
- A Start Menu shortcut is created.
- The desktop shortcut is optional and unchecked by default.
- `Launch USB Watcher` appears on the finish page.
- Windows Settings lists an uninstall entry.
- Uninstall removes the installed application files and shortcuts.

## Application checklist

- The application opens without an administrator prompt after installation.
- Connected USB devices appear.
- Search filters the visible list.
- Refresh updates the list.
- Automatic refresh can be enabled and disabled.
- Missing Rust core errors are readable.
- No report or export control appears in the interface.
