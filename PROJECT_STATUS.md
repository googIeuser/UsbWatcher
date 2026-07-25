# Project Status

## Current version

`v0.1.0` starter repository

## Current state

- Flutter interface source: ready
- Rust USB core source: ready
- USB Watcher application icon: ready
- Local Windows bootstrap script: ready
- Local development launcher: ready
- Portable Windows packaging: ready
- Inno Setup installer script: ready
- Separate Test Build workflow: ready
- Separate Stable Release workflow: ready

## Verification note

The repository was generated in a non-Windows environment, so the final Windows executable and Inno Setup installer were not compiled here. The included scripts and GitHub Actions workflows perform the Windows-specific Flutter, Rust, and Inno Setup builds on Windows.

## Known limitations

- The displayed speed is the negotiated connection speed reported by the operating system.
- A passive USB cable normally does not expose its certified maximum speed.
- Some manufacturer and serial fields may be unavailable because Windows does not cache every USB string descriptor.
- `nusb` currently represents common connection-speed categories up to SuperSpeed Plus in this application.
