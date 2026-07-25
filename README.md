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
