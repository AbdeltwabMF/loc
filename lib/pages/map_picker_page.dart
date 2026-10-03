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
import 'package:loc/themes/tokens.dart';
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
  late LatLng _center;
  bool _selecting = false;
  bool _tilesFailed = false;
  bool _tileLoaded = false;
  int _tileFailureCount = 0;

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
    _geocoding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textScaler = MediaQuery.textScalerOf(context);
    final toolbarHeight =
        (textScaler.scale(22) * 1.3 + textScaler.scale(12) * 16 / 12 + 18)
            .clamp(72.0, 144.0);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: toolbarHeight,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose destination'),
            const SizedBox(height: 2),
            Text(
              'Pan and zoom the map under the pin',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tilesFailed)
            Material(
              color: colors.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Map tiles are unavailable. You can still choose a location.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: colors.surfaceContainerHighest,
                  child: FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 14,
                      minZoom: 2,
                      maxZoom: 19,
                      backgroundColor: colors.surfaceContainerHighest,
                      onPositionChanged: (camera, hasGesture) {
                        _center = camera.center;
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        tileProvider: _tileProvider,
                        evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                        errorTileCallback: (tile, error, stackTrace) {
                          _tileFailureCount++;
                          if (mounted &&
                              !_tileLoaded &&
                              !_tilesFailed &&
                              _tileFailureCount >= 3) {
                            setState(() => _tilesFailed = true);
                          }
                        },
                        tileBuilder: (context, tileWidget, tile) {
                          if (tile.loadError) {
                            return Container(
                              color: colors.surfaceContainerHigh,
                              child: Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  color: colors.outline,
                                  size: 28,
                                ),
                              ),
                            );
                          }
                          if (!_tileLoaded && tile.imageInfo != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted || _tileLoaded) return;
                              setState(() {
                                _tileLoaded = true;
                                _tilesFailed = false;
                              });
                            });
                          }
                          return tileWidget;
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 0,
                  child: SafeArea(
                    child: Material(
                      color: colors.surface.withValues(alpha: 0.79),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Center(
                            child: Text(
                              '© OpenStreetMap contributors',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 44),
                      child: Icon(
                        Icons.location_pin,
                        size: 58,
                        color: colors.tertiary,
                        shadows: [
                          Shadow(
                            color: colors.scrim.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: colors.surface,
            elevation: 2,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.compact,
                AppSpacing.page,
                AppSpacing.page,
              ),
              child: SizedBox(
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
            scrollable: true,
            icon: const Icon(Icons.location_on_outlined),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(actionLabel),
              ),
            ],
          ),
        ) ??
        false;
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
