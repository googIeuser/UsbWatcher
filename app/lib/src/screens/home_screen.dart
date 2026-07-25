import 'dart:async';

import 'package:flutter/material.dart';

import '../models/usb_device.dart';
import '../services/usb_core_service.dart';
import '../widgets/device_card.dart';
import '../widgets/summary_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsbCoreService _usbCoreService = UsbCoreService();
  final TextEditingController _searchController = TextEditingController();

  List<UsbDevice> _devices = const <UsbDevice>[];
  Timer? _refreshTimer;
  bool _loading = true;
  bool _automaticRefresh = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  List<UsbDevice> get _visibleDevices {
    final query = _searchController.text;
    return _devices.where((device) => device.matches(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {});
  }

  Future<void> _refresh({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final devices = await _usbCoreService.listDevices();
      if (!mounted) {
        return;
      }
      setState(() {
        _devices = devices;
        _lastUpdated = DateTime.now();
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted && showSpinner) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _setAutomaticRefresh(bool enabled) {
    _refreshTimer?.cancel();
    setState(() {
      _automaticRefresh = enabled;
    });

    if (enabled) {
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => unawaited(_refresh(showSpinner: false)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleDevices = _visibleDevices;
    final highSpeedDevices = _devices
        .where((device) => (device.speedMbps ?? 0) >= 480)
        .length;
    final superspeedDevices = _devices
        .where((device) => (device.speedMbps ?? 0) >= 5000)
        .length;

    return Scaffold(
      body: SafeArea(
        child: SelectionArea(
          child: Column(
            children: <Widget>[
              _Header(
                automaticRefresh: _automaticRefresh,
                loading: _loading,
                lastUpdated: _lastUpdated,
                onAutomaticRefreshChanged: _setAutomaticRefresh,
                onRefresh: _loading ? null : () => unawaited(_refresh()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: <Widget>[
                          SummaryTile(
                            icon: Icons.usb_rounded,
                            label: 'Connected devices',
                            value: _devices.length.toString(),
                          ),
                          SummaryTile(
                            icon: Icons.speed_rounded,
                            label: 'High-speed or faster',
                            value: highSpeedDevices.toString(),
                          ),
                          SummaryTile(
                            icon: Icons.bolt_rounded,
                            label: 'SuperSpeed devices',
                            value: superspeedDevices.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by device, VID, PID, class, or USB technology',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: _searchController.clear,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_errorMessage != null)
                        _ErrorPanel(
                          message: _errorMessage!,
                          onRetry: () => unawaited(_refresh()),
                        )
                      else if (_loading && _devices.isEmpty)
                        const _LoadingPanel()
                      else if (visibleDevices.isEmpty)
                        _EmptyPanel(hasSearch: _searchController.text.isNotEmpty)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visibleDevices.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return DeviceCard(device: visibleDevices[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.automaticRefresh,
    required this.loading,
    required this.lastUpdated,
    required this.onAutomaticRefreshChanged,
    required this.onRefresh,
  });

  final bool automaticRefresh;
  final bool loading;
  final DateTime? lastUpdated;
  final ValueChanged<bool> onAutomaticRefreshChanged;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final updatedText = lastUpdated == null
        ? 'Not refreshed yet'
        : 'Updated ${_twoDigits(lastUpdated!.hour)}:'
            '${_twoDigits(lastUpdated!.minute)}:'
            '${_twoDigits(lastUpdated!.second)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.usb_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'USB Watcher',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '$updatedText · Negotiated connection information',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Auto refresh'),
              Switch(
                value: automaticRefresh,
                onChanged: onAutomaticRefreshChanged,
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: loading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'USB scan failed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(message),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            const Icon(Icons.usb_off_rounded, size: 40),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'No devices match this search.' : 'No USB devices were found.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
