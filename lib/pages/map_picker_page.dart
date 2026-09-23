import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/geocoding_service.dart';
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
    headers: {'User-Agent': 'Loc/1.0.0 (+https://loc.abdeltwab.xyz)'},
  );
  Timer? _debounce;
  List<Place> _results = const [];
  late LatLng _center;
  bool _searching = false;
  bool _selecting = false;
  int _searchGeneration = 0;

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
    _debounce?.cancel();
    _search.dispose();
    _map.dispose();
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
              onPositionChanged: (camera, _) => _center = camera.center,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                tileProvider: _tileProvider,
              ),
              SimpleAttributionWidget(
                source: const Text('OpenStreetMap contributors'),
                onTap: () => unawaited(
                  launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                backgroundColor: colors.surface.withValues(alpha: 0.85),
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
                    onChanged: _searchPlaces,
                    decoration: InputDecoration(
                      hintText: 'Search a city, station, or address',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                  if (_results.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.only(top: 8),
                      color: colors.surface,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final place = _results[index];
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(
                                place.displayName ?? 'Search result',
                                maxLines: 2,
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _center = LatLng(
                                  place.position.latitude,
                                  place.position.longitude,
                                );
                                _map.move(_center, 16);
                                setState(() => _results = const []);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton.small(
                      heroTag: 'my-location',
                      tooltip: 'Use my location',
                      onPressed: _moveToCurrent,
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
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

  void _searchPlaces(String value) {
    _debounce?.cancel();
    final generation = ++_searchGeneration;
    if (value.trim().length < 3) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 1100), () async {
      setState(() => _searching = true);
      try {
        final results = await _geocoding.search(value);
        if (mounted && generation == _searchGeneration) {
          setState(() => _results = results);
        }
      } on Object catch (error) {
        if (mounted) _showError(error);
      } finally {
        if (mounted && generation == _searchGeneration) {
          setState(() => _searching = false);
        }
      }
    });
  }

  Future<void> _moveToCurrent() async {
    try {
      final point = await context.read<AppController>().getCurrentPosition();
      _center = LatLng(point.latitude, point.longitude);
      _map.move(_center, 16);
    } on Object catch (error) {
      if (mounted) _showError(error);
    }
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
