import 'package:flutter/material.dart';

import '../models/usb_device.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({required this.device, super.key});

  final UsbDevice device;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _iconForClass(device.deviceClass),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${device.manufacturer} · VID ${device.vendorId} · PID ${device.productId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                _TechnologyBadge(
                  technology: device.technology,
                  speed: device.speed,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 24,
              runSpacing: 14,
              children: <Widget>[
                _Detail(label: 'USB descriptor', value: device.usbVersion),
                _Detail(label: 'Device class', value: device.deviceClass),
                _Detail(label: 'Bus', value: device.bus),
                _Detail(label: 'Port path', value: device.portPath),
                if (device.serialNumber != null)
                  _Detail(label: 'Serial number', value: device.serialNumber!),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.info_outline_rounded, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      device.assessment,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForClass(String deviceClass) {
    final value = deviceClass.toLowerCase();
    if (value.contains('storage')) return Icons.storage_rounded;
    if (value.contains('audio')) return Icons.headphones_rounded;
    if (value.contains('video') || value.contains('imaging')) {
      return Icons.videocam_rounded;
    }
    if (value.contains('human interface')) return Icons.keyboard_rounded;
    if (value.contains('hub')) return Icons.hub_rounded;
    if (value.contains('wireless')) return Icons.wifi_rounded;
    if (value.contains('printer')) return Icons.print_rounded;
    return Icons.usb_rounded;
  }
}

class _TechnologyBadge extends StatelessWidget {
  const _TechnologyBadge({required this.technology, required this.speed});

  final String technology;
  final String speed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            technology,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            speed,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 3),
          Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
