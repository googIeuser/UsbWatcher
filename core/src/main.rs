use nusb::{MaybeFuture, Speed};
use serde::Serialize;
use std::{env, process};

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct UsbDeviceRecord {
    id: String,
    name: String,
    manufacturer: String,
    vendor_id: String,
    product_id: String,
    usb_version: String,
    technology: String,
    speed: String,
    speed_mbps: Option<u32>,
    device_class: String,
    bus: String,
    port_path: String,
    serial_number: Option<String>,
    assessment: String,
}

fn main() {
    let arguments: Vec<String> = env::args().skip(1).collect();

    if arguments.iter().any(|argument| argument == "--version") {
        println!(env!("CARGO_PKG_VERSION"));
        return;
    }

    let pretty = arguments.iter().any(|argument| argument == "--pretty");

    match list_usb_devices() {
        Ok(devices) => {
            let serialized = if pretty {
                serde_json::to_string_pretty(&devices)
            } else {
                serde_json::to_string(&devices)
            };

            match serialized {
                Ok(json) => println!("{json}"),
                Err(error) => fail(&format!("Failed to serialize USB device data: {error}")),
            }
        }
        Err(error) => fail(&error),
    }
}

fn list_usb_devices() -> Result<Vec<UsbDeviceRecord>, String> {
    let device_iterator = nusb::list_devices()
        .wait()
        .map_err(|error| format!("USB enumeration failed: {error}"))?;

    let mut devices = Vec::new();

    for device in device_iterator {
        let vendor_id = device.vendor_id();
        let product_id = device.product_id();
        let port_path = format_port_path(device.port_chain());
        let bus = device.bus_id().to_owned();
        let speed = device.speed();
        let (technology, speed_label, speed_mbps) = describe_speed(speed, device.usb_version());
        let name = device
            .product_string()
            .filter(|value| !value.trim().is_empty())
            .map(ToOwned::to_owned)
            .unwrap_or_else(|| format!("USB Device {vendor_id:04X}:{product_id:04X}"));
        let manufacturer = device
            .manufacturer_string()
            .filter(|value| !value.trim().is_empty())
            .unwrap_or("Unknown")
            .to_owned();

        let id = format!(
            "{}:{}:{vendor_id:04X}:{product_id:04X}",
            bus,
            if port_path.is_empty() { "root" } else { &port_path }
        );

        devices.push(UsbDeviceRecord {
            id,
            name,
            manufacturer,
            vendor_id: format!("{vendor_id:04X}"),
            product_id: format!("{product_id:04X}"),
            usb_version: format_bcd_version(device.usb_version()),
            technology,
            speed: speed_label,
            speed_mbps,
            device_class: usb_class_name(device.class()).to_owned(),
            bus,
            port_path: if port_path.is_empty() {
                "Root".to_owned()
            } else {
                port_path
            },
            serial_number: device.serial_number().map(ToOwned::to_owned),
            assessment: "Negotiated connection speed reported by the operating system; this does not certify the cable's maximum rating.".to_owned(),
        });
    }

    devices.sort_by(|left, right| {
        left.name
            .to_lowercase()
            .cmp(&right.name.to_lowercase())
            .then_with(|| left.vendor_id.cmp(&right.vendor_id))
            .then_with(|| left.product_id.cmp(&right.product_id))
    });

    Ok(devices)
}

fn describe_speed(speed: Option<Speed>, usb_version: u16) -> (String, String, Option<u32>) {
    match speed {
        Some(Speed::Low) => ("USB 1.x".to_owned(), "1.5 Mbps".to_owned(), Some(1)),
        Some(Speed::Full) => ("USB 1.1".to_owned(), "12 Mbps".to_owned(), Some(12)),
        Some(Speed::High) => ("USB 2.0".to_owned(), "480 Mbps".to_owned(), Some(480)),
        Some(Speed::Super) => ("USB 3.2 Gen 1".to_owned(), "5 Gbps".to_owned(), Some(5_000)),
        Some(Speed::SuperPlus) => ("USB 3.2 Gen 2".to_owned(), "10 Gbps".to_owned(), Some(10_000)),
        Some(_) => (technology_from_version(usb_version), "Unknown".to_owned(), None),
        None => (technology_from_version(usb_version), "Not reported".to_owned(), None),
    }
}

fn technology_from_version(version: u16) -> String {
    match version {
        value if value >= 0x0320 => "USB 3.2".to_owned(),
        value if value >= 0x0310 => "USB 3.1".to_owned(),
        value if value >= 0x0300 => "USB 3.0".to_owned(),
        value if value >= 0x0200 => "USB 2.0".to_owned(),
        value if value >= 0x0110 => "USB 1.1".to_owned(),
        value if value > 0 => "USB 1.x".to_owned(),
        _ => "Unknown".to_owned(),
    }
}

fn format_bcd_version(value: u16) -> String {
    let major = (value >> 8) & 0xFF;
    let minor_tens = (value >> 4) & 0x0F;
    let minor_ones = value & 0x0F;
    format!("{major:X}.{minor_tens:X}{minor_ones:X}")
}

fn format_port_path(path: &[u8]) -> String {
    path.iter()
        .map(u8::to_string)
        .collect::<Vec<_>>()
        .join(".")
}

fn usb_class_name(class_code: u8) -> &'static str {
    match class_code {
        0x00 => "Defined by Interface",
        0x01 => "Audio",
        0x02 => "Communications",
        0x03 => "Human Interface Device",
        0x05 => "Physical",
        0x06 => "Imaging",
        0x07 => "Printer",
        0x08 => "Mass Storage",
        0x09 => "Hub",
        0x0A => "CDC Data",
        0x0B => "Smart Card",
        0x0D => "Content Security",
        0x0E => "Video",
        0x0F => "Personal Healthcare",
        0x10 => "Audio/Video",
        0x11 => "Billboard",
        0x12 => "USB Type-C Bridge",
        0xDC => "Diagnostic",
        0xE0 => "Wireless Controller",
        0xEF => "Miscellaneous",
        0xFE => "Application Specific",
        0xFF => "Vendor Specific",
        _ => "Unknown",
    }
}

fn fail(message: &str) -> ! {
    eprintln!("{message}");
    process::exit(1);
}
