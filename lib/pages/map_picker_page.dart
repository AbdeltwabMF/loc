import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/geocoding_service.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({this.initialPlace, super.key});

  final Place? initialPlace;

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final _map = MapController();
  final _geocoding = GeocodingService();
  final _tileProvider = NetworkTileProvider(
    headers: {'User-Agent': AppMetadata.current.mapUserAgent},
  );
  final _tileReset = StreamController<void>.broadcast();
  late LatLng _center;
  bool _selecting = false;
  bool _mapUnavailable = false;
  bool _tileErrorPending = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPlace?.position;
    _center = LatLng(
      initial?.latitude ?? 30.0444,
      initial?.longitude ?? 31.2357,
    );
  }

  @override
  void dispose() {
    _map.dispose();
    _tileReset.close();
    _geocoding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose destination'),
            SizedBox(height: 2),
            Text(
              'Pan and zoom the map under the pin',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              minZoom: 2,
              maxZoom: 19,
              onPositionChanged: (camera, hasGesture) {
                _center = camera.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                tileProvider: _tileProvider,
                reset: _tileReset.stream,
                evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                errorTileCallback: (_, error, _) => _handleTileError(error),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ColoredBox(
                      color: colors.surface.withValues(alpha: 0.8),
                      child: InkWell(
                        onTap: () => unawaited(
                          launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '© OpenStreetMap contributors',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 44),
                child: Icon(
                  Icons.location_pin,
                  size: 58,
                  color: colors.tertiary,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_mapUnavailable)
                    Card(
                      margin: const EdgeInsets.only(top: 8),
                      color: colors.errorContainer,
                      child: ListTile(
                        iconColor: colors.onErrorContainer,
                        textColor: colors.onErrorContainer,
                        leading: const Icon(Icons.wifi_off_rounded),
                        title: const Text('Map is unavailable'),
                        subtitle: const Text(
                          'Check internet access and allow Loc through any VPN '
                          'or firewall.',
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: _retryTiles,
                          child: const Text('Retry'),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton.small(
                      heroTag: 'my-location',
                      tooltip: 'My location',
                      onPressed: _moveToCurrent,
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selecting ? null : _select,
                      icon: _selecting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _selecting ? 'Finding address…' : 'Use this location',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToCurrent() async {
    try {
      final point = await context.read<AppController>().getCurrentPosition();
      if (!mounted) return;
      _center = LatLng(point.latitude, point.longitude);
      _map.move(_center, 16);
    } on Object catch (error) {
      if (mounted) await _showLocationAction(error);
    }
  }

  Future<void> _showLocationAction(Object error) async {
    final state = context.read<AppController>();
    LocationAccessStatus status;
    try {
      status = await state.locationAccessStatus();
    } on Object {
      if (mounted) _showError(error);
      return;
    }
    if (!mounted) return;

    if (status == LocationAccessStatus.serviceDisabled) {
      await state.openLocationSettings();
      return;
    }

    final action = switch (status) {
      LocationAccessStatus.permissionDenied => await _showLocationDialog(
        title: 'Allow location access',
        message: 'Loc needs your permission to center the map where you are.',
        actionLabel: 'Allow',
      ),
      LocationAccessStatus.settingsRequired => await _showLocationDialog(
        title: 'Allow location access',
        message: 'Enable location permission for Loc in Android settings.',
        actionLabel: 'Open settings',
      ),
      LocationAccessStatus.ready => false,
      LocationAccessStatus.serviceDisabled => false,
    };
    if (!mounted) return;

    switch (status) {
      case LocationAccessStatus.serviceDisabled:
        return;
      case LocationAccessStatus.permissionDenied:
        if (action) await _moveToCurrent();
      case LocationAccessStatus.settingsRequired:
        if (action) await state.openAppSettings();
      case LocationAccessStatus.ready:
        _showError(error);
    }
  }

  Future<bool> _showLocationDialog({
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.location_on_outlined),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(actionLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleTileError(Object _) {
    if (_mapUnavailable || _tileErrorPending) return;
    _tileErrorPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_mapUnavailable) {
        setState(() => _mapUnavailable = true);
      }
      _tileErrorPending = false;
    });
  }

  void _retryTiles() {
    _tileErrorPending = false;
    setState(() => _mapUnavailable = false);
    _tileReset.add(null);
  }

  Future<void> _select() async {
    setState(() => _selecting = true);
    final point = Point(
      latitude: _center.latitude,
      longitude: _center.longitude,
    );
    Place place;
    try {
      place = await _geocoding.reverse(point);
    } on Object {
      place = Place(position: point);
    }
    if (mounted) Navigator.of(context).pop(place);
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
