# Architecture

## Overview

USB Watcher is split into two local processes.

```text
Flutter Windows UI
        |
        | Process execution + JSON over stdout
        v
Rust USB Core
        |
        v
Windows USB device information through nusb
```

## Flutter application

The Flutter application is responsible for:

- Window rendering
- Search and filtering
- Manual and timed refresh
- User-facing error handling
- Starting the Rust core process
- Parsing the JSON response

## Rust core

The Rust executable is responsible for:

- Enumerating USB devices
- Reading available USB descriptor values
- Reading the negotiated connection speed exposed by the operating system
- Mapping USB class codes to readable labels
- Mapping speed categories to USB technology labels
- Serializing the result as JSON

## Why a separate Rust process

The initial architecture uses a small process boundary instead of generated FFI bindings because it:

- Keeps Flutter and Rust builds independently testable
- Makes crashes and USB enumeration errors easier to isolate
- Avoids tying the first release to one FFI code generator version
- Produces a simple, inspectable JSON contract
- Can later be replaced by `flutter_rust_bridge` without changing the screen model

## JSON contract

The Rust core prints a JSON array. Each item contains:

```json
{
  "id": "bus:port:vid:pid",
  "name": "USB device name",
  "manufacturer": "Manufacturer or Unknown",
  "vendorId": "1234",
  "productId": "ABCD",
  "usbVersion": "3.20",
  "technology": "USB 3.2 Gen 1",
  "speed": "5 Gbps",
  "speedMbps": 5000,
  "deviceClass": "Mass Storage",
  "bus": "bus identifier",
  "portPath": "1.4.2",
  "serialNumber": null,
  "assessment": "Negotiated speed reported by the operating system."
}
```

## Future direction

A later release may replace the process boundary with `flutter_rust_bridge` when direct hot-plug streams and lower-latency native calls become useful.
