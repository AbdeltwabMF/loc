// Copyright (C) 2022 https://github.com/AbduzZami
// Copyright (C) 2023 Abd El-Twab M. Fakhry

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:loc/styles/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/widgets/buttons.dart';

const String osmBaseUrl = 'https://nominatim.openstreetmap.org';

class OsmMapViewScreen extends StatefulWidget {
  OsmMapViewScreen({super.key});

  // Initial center for the map
  final LocationData center =
      LocationData(latitude: 30.05336456509493, longitude: 31.230701671759462);

  @override
  State<OsmMapViewScreen> createState() => _OsmMapViewScreen();
}

class _OsmMapViewScreen extends State<OsmMapViewScreen> {
  MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<LocationData> _options = <LocationData>[];
  Timer? _debounce;

  @override
  void initState() {
    _mapController = MapController();
    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        // Handle event.center.
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
                child: FlutterMap(
              options: MapOptions(
                center: LatLng(widget.center.latitude, widget.center.longitude),
                zoom: 15.0,
                maxZoom: 30,
                minZoom: 6,
              ),
              mapController: _mapController,
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
              ],
            )),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5 + 12,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Text(
                        _searchController.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 62, 23, 129),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 56,
                    color: AppColors.fg.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 224,
              right: 8,
              child: FloatingActionButton(
                backgroundColor: AppColors.fg.withOpacity(0.9),
                elevation: 0,
                heroTag: 'btn1',
                onPressed: () {
                  _mapController.move(
                      _mapController.center, _mapController.zoom + 1);
                },
                tooltip: 'Zoom in',
                child: const Icon(
                  Icons.zoom_in_map,
                  color: AppColors.linen,
                ),
              ),
            ),
            Positioned(
              bottom: 152,
              right: 8,
              child: FloatingActionButton(
                backgroundColor: AppColors.fg.withOpacity(0.9),
                elevation: 0,
                heroTag: 'btn2',
                onPressed: () {
                  _mapController.move(
                      _mapController.center, _mapController.zoom - 1);
                },
                tooltip: 'Zoom out',
                child: const Icon(
                  Icons.zoom_out_map,
                  color: AppColors.linen,
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 8,
              child: FloatingActionButton(
                backgroundColor: AppColors.fg.withOpacity(0.9),
                elevation: 0,
                heroTag: 'btn3',
                onPressed: () {
                  // Move to the current location, if can not, move to the initial position
                  getCurrentLocation().then((value) {
                    _mapController.move(LatLng(value.latitude, value.longitude),
                        _mapController.zoom);

                    debugPrint(value.latitude.toString());
                    debugPrint(value.longitude.toString());
                  }).onError((error, stackTrace) {
                    _mapController.move(
                        LatLng(widget.center.latitude, widget.center.longitude),
                        _mapController.zoom);

                    debugPrint(error.toString());
                    debugPrint(stackTrace.toString());
                  });
                },
                tooltip: 'My location',
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.linen,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.fg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    prefixIconColor: AppColors.linen,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.linen,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    contentPadding: EdgeInsets.all(4),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.yellowRed,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    hintText: 'Search Location',
                    hintStyle: TextStyle(
                      fontFamily: 'Fantasque',
                      fontSize: 18,
                      color: AppColors.linen,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (String value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();

                    _debounce = Timer(
                      const Duration(milliseconds: 1000),
                      () async {
                        try {
                          final decodedResponse =
                              await osmSearch(value).onError(
                            (error, stackTrace) =>
                                Future.error(error!, stackTrace),
                          );

                          _options = decodedResponse
                              .map(
                                (e) => LocationData(
                                  latitude: double.parse(e['lat']),
                                  longitude: double.parse(e['lon']),
                                  displayName: e['display_name'],
                                ),
                              )
                              .toList();
                        } finally {
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                    );
                  },
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'NotoArabic',
                    color: AppColors.linen,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 64,
              right: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.fg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: StatefulBuilder(
                  builder: ((context, setState) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _options.length > 5 ? 5 : _options.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          title: Text(
                            _options[index].displayName!,
                            maxLines: 2,
                            style: const TextStyle(
                              fontFamily: 'NotoArabic',
                              fontSize: 14,
                              color: AppColors.linen,
                            ),
                          ),
                          subtitle: Text(
                            '${_options[index].latitude}, ${_options[index].longitude}',
                            style: const TextStyle(
                              fontFamily: 'Fantasque',
                              fontSize: 14,
                              color: AppColors.lavender,
                            ),
                          ),
                          onTap: () {
                            _mapController.move(
                                LatLng(
                                  _options[index].latitude,
                                  _options[index].longitude,
                                ),
                                15.0);

                            _focusNode.unfocus();
                            _options.clear();
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PickLocationButton(onPressed: () async {
                    pickLocationData().then((value) {
                      Navigator.of(context).pop<LocationData>(value);
                    });
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<LocationData> pickLocationData() async {
    final latitude = _mapController.center.latitude;
    final longitude = _mapController.center.longitude;
    LocationData locationData =
        LocationData(latitude: latitude, longitude: longitude);

    final decodedResponse = await osmReverse(locationData);
    locationData.displayName = decodedResponse['display_name'] ?? '';

    return locationData;
  }
}

class LocationData {
  double latitude;
  double longitude;
  String? displayName = '';

  LocationData(
      {required this.latitude, required this.longitude, this.displayName});
}

// Open street Map APIs
Future<Map<String, dynamic>> osmReverse(LocationData locationData) async {
  try {
    String reverseUrl =
        '$osmBaseUrl/reverse?format=json&lat=${locationData.latitude}&lon=${locationData.longitude}&zoom=16&addressdetails=1';
    final response = await http.get(Uri.parse(reverseUrl));
    if (response.statusCode != 200) {
      return Future.error(response.statusCode);
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  } catch (error, stackTrace) {
    return Future.error(error, stackTrace);
  }
}

Future<List<dynamic>> osmSearch(String searchValue) async {
  try {
    String searchUrl =
        '$osmBaseUrl/search?q=$searchValue&format=json&polygon_geojson=1&addressdetails=1';
    final response = await http.get(Uri.parse(searchUrl));
    if (response.statusCode != 200) {
      return Future.error(response.statusCode);
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
  } catch (error, stackTrace) {
    return Future.error(error, stackTrace);
  }
}
