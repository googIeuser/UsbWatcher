# Windows Development and Installer Setup

USB Watcher uses Flutter for the interface, Rust for USB enumeration, and Inno Setup for the Windows installation wizard.

## 1. Install Flutter stable

Install the Flutter SDK, add its `bin` directory to `PATH`, and enable Windows desktop support.

```powershell
flutter --version
flutter config --enable-windows-desktop
```

## 2. Install Visual Studio 2022

Install Visual Studio 2022 with the **Desktop development with C++** workload.

```powershell
flutter doctor -v
```

## 3. Install Rust stable

Install Rust through rustup and keep the default stable MSVC toolchain.

```powershell
rustc --version
cargo --version
```

## 4. Install Inno Setup

Inno Setup is required only when creating the Windows installer.

```powershell
winget install --id JRSoftware.InnoSetup -e -s winget -i
```

The build scripts detect Inno Setup 6 or 7 automatically.

## 5. Check the environment

Double-click:

```text
CHECK_ENVIRONMENT.cmd
```

## 6. Run USB Watcher in development mode

```text
RUN_USB_WATCHER.cmd
```

## 7. Build installer and portable package

```text
BUILD_RELEASE.cmd
```

Or:

```powershell
.\scripts\build-windows.ps1 -Version 0.1.0
```

## Generated files

The first run generates `app/windows` and `app/.metadata`. The build also creates `app/build`, `core/target`, and `artifacts`. These paths are ignored by Git.
