import 'package:flutter_test/flutter_test.dart';
import 'package:usb_watcher/src/models/usb_device.dart';

void main() {
  test('USB device search checks identifiers and technology', () {
    const device = UsbDevice(
      id: 'test',
      name: 'Example Storage',
      manufacturer: 'Example Vendor',
      vendorId: '1234',
      productId: 'ABCD',
      usbVersion: '3.20',
      technology: 'USB 3.2 Gen 1',
      speed: '5 Gbps',
      speedMbps: 5000,
      deviceClass: 'Mass Storage',
      bus: '1',
      portPath: '2.3',
      serialNumber: null,
      assessment: 'Test',
    );

    expect(device.matches('ABCD'), isTrue);
    expect(device.matches('gen 1'), isTrue);
    expect(device.matches('printer'), isFalse);
  });
}
