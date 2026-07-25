import 'dart:convert';
import 'dart:io';

import '../models/usb_device.dart';

class UsbCoreException implements Exception {
  const UsbCoreException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UsbCoreService {
  Future<List<UsbDevice>> listDevices() async {
    final executable = await _findCoreExecutable();
    final result = await Process.run(
      executable,
      const <String>['list'],
      runInShell: false,
    );

    if (result.exitCode != 0) {
      final error = (result.stderr as String).trim();
      throw UsbCoreException(
        error.isEmpty
            ? 'The Rust USB core exited with code ${result.exitCode}.'
            : error,
      );
    }

    try {
      final decoded = jsonDecode(result.stdout as String);
      if (decoded is! List<dynamic>) {
        throw const FormatException('The root JSON value is not a list.');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(UsbDevice.fromJson)
          .toList(growable: false);
    } on FormatException catch (error) {
      throw UsbCoreException('The Rust USB core returned invalid JSON: $error');
    }
  }

  Future<String> _findCoreExecutable() async {
    final candidates = <String>{
      _join(File(Platform.resolvedExecutable).parent.path, 'usb_watcher_core.exe'),
      _join(Directory.current.path, 'usb_watcher_core.exe'),
      _join(Directory.current.path, '..', 'core', 'target', 'debug', 'usb_watcher_core.exe'),
      _join(Directory.current.path, '..', 'core', 'target', 'release', 'usb_watcher_core.exe'),
      _join(Directory.current.path, 'core', 'target', 'debug', 'usb_watcher_core.exe'),
      _join(Directory.current.path, 'core', 'target', 'release', 'usb_watcher_core.exe'),
    };

    for (final candidate in candidates) {
      if (await File(candidate).exists()) {
        return candidate;
      }
    }

    throw UsbCoreException(
      'usb_watcher_core.exe was not found. Run the application with '
      'RUN_USB_WATCHER.cmd or execute scripts/run-dev.ps1.',
    );
  }

  String _join(String first, String second, [
    String? third,
    String? fourth,
    String? fifth,
    String? sixth,
  ]) {
    final parts = <String>[first, second];
    for (final part in <String?>[third, fourth, fifth, sixth]) {
      if (part != null) {
        parts.add(part);
      }
    }
    return parts.join(Platform.pathSeparator);
  }
}
