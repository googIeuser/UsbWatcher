class UsbDevice {
  const UsbDevice({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.vendorId,
    required this.productId,
    required this.usbVersion,
    required this.technology,
    required this.speed,
    required this.speedMbps,
    required this.deviceClass,
    required this.bus,
    required this.portPath,
    required this.serialNumber,
    required this.assessment,
  });

  factory UsbDevice.fromJson(Map<String, dynamic> json) {
    return UsbDevice(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown USB Device',
      manufacturer: json['manufacturer'] as String? ?? 'Unknown',
      vendorId: json['vendorId'] as String? ?? '----',
      productId: json['productId'] as String? ?? '----',
      usbVersion: json['usbVersion'] as String? ?? 'Unknown',
      technology: json['technology'] as String? ?? 'Unknown',
      speed: json['speed'] as String? ?? 'Not reported',
      speedMbps: (json['speedMbps'] as num?)?.toInt(),
      deviceClass: json['deviceClass'] as String? ?? 'Unknown',
      bus: json['bus'] as String? ?? 'Unknown',
      portPath: json['portPath'] as String? ?? 'Unknown',
      serialNumber: json['serialNumber'] as String?,
      assessment: json['assessment'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String manufacturer;
  final String vendorId;
  final String productId;
  final String usbVersion;
  final String technology;
  final String speed;
  final int? speedMbps;
  final String deviceClass;
  final String bus;
  final String portPath;
  final String? serialNumber;
  final String assessment;

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return <String>[
      name,
      manufacturer,
      vendorId,
      productId,
      usbVersion,
      technology,
      speed,
      deviceClass,
      bus,
      portPath,
      serialNumber ?? '',
    ].any((value) => value.toLowerCase().contains(normalizedQuery));
  }
}
