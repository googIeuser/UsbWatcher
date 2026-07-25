# USB Watcher

USB Watcher is an open-source Windows desktop application that inspects connected USB devices and shows the USB technology, negotiated connection speed, device identifiers, class, and connection path reported by the operating system.

## Important technical limitation

A standard passive USB cable usually does not identify its certified maximum data rate to Windows. USB Watcher therefore reports the **negotiated device connection speed** and USB descriptor information that Windows can expose. This is useful for detecting likely bottlenecks, but it is not a cable certification tool.

## Technology stack

- **Flutter** for the Windows desktop interface
- **Rust** for USB enumeration and analysis
- **nusb** for cross-platform USB device information
- A small JSON protocol between the Flutter application and the Rust core
- **Inno Setup** for the native Windows installation wizard

The Rust core runs locally as `usb_watcher_core.exe`. No server, account, telemetry, or cloud connection is required.

## v0.1.0 features

- List connected USB devices
- Show VID, PID, USB descriptor version, device class, and port path
- Show the negotiated USB connection speed reported by the operating system
- Translate common speed levels into readable USB technology labels
- Search devices by name, ID, manufacturer, technology, or class
- Manual refresh
- Optional 10-second automatic refresh
- Modern dark Windows desktop interface
- Native English Inno Setup installer
- Start Menu shortcut and optional desktop shortcut
- No report or export feature

## Repository layout

```text
USB-Watcher/
├── app/                    Flutter Windows desktop application
├── core/                   Rust USB enumeration executable
├── installer/              Inno Setup script and application icon
├── docs/                   Architecture, installation, and testing notes
├── scripts/                Bootstrap, development, packaging, and installer scripts
├── .github/workflows/      Separate test build and stable release workflows
├── RUN_USB_WATCHER.cmd     One-click local development launcher
├── BUILD_RELEASE.cmd       One-click installer and portable-package builder
└── CHECK_ENVIRONMENT.cmd   Checks required development tools
```

## Requirements for local development

- Windows 10 or Windows 11, x64
- Flutter stable with Windows desktop support enabled
- Visual Studio 2022 with **Desktop development with C++**
- Rust stable with Cargo
- Inno Setup 6 or 7 for creating the installer

Run this first:

```text
CHECK_ENVIRONMENT.cmd
```

Then start the application:

```text
RUN_USB_WATCHER.cmd
```

The first run creates the generated Flutter Windows runner files, applies the USB Watcher icon and product name, downloads dependencies, builds the Rust core, and launches the Flutter application.

## Build the Windows installer locally

Double-click:

```text
BUILD_RELEASE.cmd
```

Or use PowerShell:

```powershell
.\scripts\build-windows.ps1 -Version 0.1.0
```

The build creates:

```text
artifacts/USB_Watcher_Setup_0.1.0.exe
artifacts/USB-Watcher-v0.1.0-win-x64.zip
artifacts/SHA256SUMS.txt
```

## Test Build workflow

Open **Actions → Test Build → Run workflow**. This creates the installer, portable ZIP, and checksums as a downloadable Actions artifact. It does not publish a GitHub Release. Test artifacts are retained for one day.

## Stable Release workflow

After testing, open **Actions → Stable Release → Run workflow**, enter a version such as `0.1.0`, and run it. The workflow publishes:

- `USB_Watcher_Setup_0.1.0.exe`
- `USB-Watcher-v0.1.0-win-x64.zip`
- `SHA256SUMS.txt`

The GitHub Release tag is `v0.1.0`.

## Installer behavior

The English-only Inno Setup wizard installs USB Watcher under Program Files, creates a Start Menu shortcut, optionally creates a desktop shortcut, registers an uninstaller, and can launch USB Watcher when setup finishes.

## Roadmap

- **v0.1:** Device list, negotiated speed, USB technology labels, search, refresh, Windows installer
- **v0.2:** Better Windows topology and host-controller analysis
- **v0.3:** USB Type-C and USB Power Delivery information where Windows exposes it
- **v0.4:** Bottleneck warnings and device/port capability comparison
- **v1.0:** Polished interface, localization support, stable hot-plug monitoring

## Privacy

All USB information is processed locally. USB Watcher does not send telemetry and does not create reports.

## License

MIT License. See [LICENSE](LICENSE).
