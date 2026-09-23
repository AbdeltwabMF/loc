import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/app_diagnostics.dart';
import 'package:loc/data/services/geocoding_service.dart';
import 'package:loc/text_direction.dart';
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
  final _search = TextEditingController();
  final _geocoding = GeocodingService();
  final _tileProvider = NetworkTileProvider(
    headers: {'User-Agent': AppMetadata.current.mapUserAgent},
  );
  final _tileReset = StreamController<void>.broadcast();
  List<Place> _results = const [];
  late LatLng _center;
  String? _selectedName;
  bool _searching = false;
  bool _hasSearched = false;
  bool _selecting = false;
  bool _mapUnavailable = false;
  bool _tileErrorPending = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPlace?.position;
    _selectedName = widget.initialPlace?.displayName;
    _center = LatLng(
      initial?.latitude ?? 30.0444,
      initial?.longitude ?? 31.2357,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    _map.dispose();
    _tileReset.close();
    _geocoding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Choose destination')),
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
                setState(() {
                  _center = camera.center;
                  if (hasGesture) _selectedName = null;
                });
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
                padding: const EdgeInsets.only(bottom: 180),
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
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) {
                      if (_results.isEmpty && !_hasSearched) return;
                      setState(() {
                        _results = const [];
                        _hasSearched = false;
                      });
                    },
                    onSubmitted: _searchPlaces,
                    decoration: InputDecoration(
                      hintText: 'Search a city, station, or address',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              tooltip: 'Search',
                              onPressed: () => _searchPlaces(_search.text),
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                    ),
                  ),
                  if (_mapUnavailable)
                    Card(
                      margin: const EdgeInsets.only(top: 8),
                      color: colors.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.wifi_off_rounded),
                        title: const Text('Map is unavailable'),
                        subtitle: const Text(
                          'Check internet access and allow Loc through any VPN '
                          'or firewall.',
                        ),
                        trailing: TextButton(
                          onPressed: _retryTiles,
                          child: const Text('Retry'),
                        ),
                      ),
                    ),
                  if (_results.isNotEmpty)
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: Card(
                          margin: const EdgeInsets.only(top: 8),
                          color: colors.surfaceContainerHigh,
                          elevation: 3,
                          shadowColor: colors.shadow.withValues(alpha: 0.25),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: _results.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: colors.outlineVariant,
                            ),
                            itemBuilder: (context, index) {
                              final place = _results[index];
                              final name = place.displayName ?? 'Search result';
                              return ListTile(
                                minVerticalPadding: 12,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.place_outlined),
                                ),
                                title: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: textDirectionFor(name),
                                ),
                                subtitle: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    '${place.position.latitude.toStringAsFixed(4)}, '
                                    '${place.position.longitude.toStringAsFixed(4)}',
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _center = LatLng(
                                    place.position.latitude,
                                    place.position.longitude,
                                  );
                                  _selectedName = place.displayName;
                                  _map.move(_center, 16);
                                  setState(() {
                                    _results = const [];
                                    _hasSearched = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  if (_hasSearched && _results.isEmpty)
                    Card(
                      margin: const EdgeInsets.only(top: 8),
                      color: colors.surfaceContainerHigh,
                      child: const ListTile(
                        leading: Icon(Icons.search_off_rounded),
                        title: Text('No places found'),
                        subtitle: Text('Try a more specific search.'),
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
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedName ?? 'Dropped pin',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: textDirectionFor(
                                    _selectedName ?? 'Dropped pin',
                                  ),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '${_center.latitude.toStringAsFixed(4)}, '
                                  '${_center.longitude.toStringAsFixed(4)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Future<void> _searchPlaces(String value) async {
    if (_searching) return;
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _results = const [];
        _hasSearched = false;
      });
      _showError('Enter at least 3 characters.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _hasSearched = false;
      _results = const [];
    });
    try {
      final results = await _geocoding.search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _hasSearched = true;
        });
      }
    } on Object catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _moveToCurrent() async {
    try {
      final point = await context.read<AppController>().getCurrentPosition();
      setState(() {
        _center = LatLng(point.latitude, point.longitude);
        _selectedName = null;
      });
      _map.move(_center, 16);
    } on Object catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _handleTileError(Object error) {
    if (_mapUnavailable || _tileErrorPending) return;
    _tileErrorPending = true;
    AppDiagnostics.record('map.tiles', error);
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
