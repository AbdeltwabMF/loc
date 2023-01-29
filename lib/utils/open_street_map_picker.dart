// Copyright (C) 2022 https://github.com/AbduzZami
// Copyright (C) 2023 Abd El-Twab M. Fakhry

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:loc/styles/colors.dart';
import 'package:loc/widgets/buttons.dart';

class OpenStreetMapSearchAndPick extends StatefulWidget {
  const OpenStreetMapSearchAndPick({
    Key? key,
    required this.center,
    required this.onPicked,
  }) : super(key: key);

  final LatLong center;
  final void Function(PickedData pickedData) onPicked;

  @override
  State<OpenStreetMapSearchAndPick> createState() =>
      _OpenStreetMapSearchAndPickState();
}

class _OpenStreetMapSearchAndPickState
    extends State<OpenStreetMapSearchAndPick> {
  MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  Timer? _debounce;
  final client = http.Client();

  void setNameCurrentPos() async {
    double latitude = _mapController.center.latitude;
    double longitude = _mapController.center.longitude;

    _searchController.text = await getAddress(latitude, longitude);
    setState(() {});
  }

  void setNameCurrentPosAtInit() async {
    double latitude = widget.center.latitude;
    double longitude = widget.center.longitude;

    _searchController.text = await getAddress(latitude, longitude);
    setState(() {});
  }

  @override
  void initState() {
    _mapController = MapController();
    setNameCurrentPosAtInit();

    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        _searchController.text =
            await getAddress(event.center.latitude, event.center.longitude);
        setState(() {});
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
    OutlineInputBorder inputBorder = const OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.darkBlue,
        width: 2,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    );
    OutlineInputBorder inputFocusBorder = const OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.darkBlue,
        width: 2,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    );

    // String? _autocompleteSelection;
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
              child: FlutterMap(
            options: MapOptions(
                center: LatLng(widget.center.latitude, widget.center.longitude),
                zoom: 15.0,
                maxZoom: 18,
                minZoom: 6),
            mapController: _mapController,
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                // attributionBuilder: (_) {
                //   return Text("© OpenStreetMap contributors");
                // },
              ),
            ],
          )),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Text(
                      _searchController.text,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Icon(Icons.location_pin,
                    size: 50, color: AppColors.darkBlue),
              ),
            ),
          ),
          Positioned(
            bottom: 224,
            right: 8,
            child: FloatingActionButton(
              backgroundColor: AppColors.darkGreen,
              elevation: 0,
              heroTag: 'btn1',
              onPressed: () {
                _mapController.move(
                    _mapController.center, _mapController.zoom + 1);
              },
              tooltip: 'Zoom in',
              child: const Icon(Icons.zoom_in_map),
            ),
          ),
          Positioned(
            bottom: 152,
            right: 8,
            child: FloatingActionButton(
              backgroundColor: AppColors.darkGreen,
              elevation: 0,
              heroTag: 'btn2',
              onPressed: () {
                _mapController.move(
                    _mapController.center, _mapController.zoom - 1);
              },
              tooltip: 'Zoom out',
              child: const Icon(Icons.zoom_out_map),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 8,
            child: FloatingActionButton(
              backgroundColor: AppColors.darkGreen,
              elevation: 0,
              heroTag: 'btn3',
              onPressed: () {
                _mapController.move(
                    LatLng(widget.center.latitude, widget.center.longitude),
                    _mapController.zoom);
                setNameCurrentPos();
              },
              tooltip: 'My location',
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      border: inputBorder,
                      contentPadding: const EdgeInsets.all(12),
                      focusedBorder: inputFocusBorder,
                      hintText: 'Search Location',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (String value) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();

                      _debounce = Timer(
                        const Duration(milliseconds: 2000),
                        () async {
                          try {
                            final decodedResponse = await searchPhrase(value)
                                .onError((error, stackTrace) =>
                                    Future.error(error!, stackTrace));
                            _options = decodedResponse
                                .map((e) => OSMdata(
                                    displayname: e['display_name'],
                                    lat: double.parse(e['lat']),
                                    lon: double.parse(e['lon'])))
                                .toList();
                          } finally {
                            setState(() {});
                          }
                        },
                      );
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoArabic',
                    ),
                  ),
                  StatefulBuilder(builder: ((context, setState) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _options.length > 5 ? 5 : _options.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_options[index].displayname),
                            subtitle: Text(
                                '${_options[index].lat},${_options[index].lon}'),
                            onTap: () {
                              _mapController.move(
                                  LatLng(
                                      _options[index].lat, _options[index].lon),
                                  15.0);

                              _focusNode.unfocus();
                              _options.clear();
                              setState(() {});
                            },
                          );
                        });
                  })),
                ],
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
                child: MapPickLocationButton(onPressed: () async {
                  pickData().then((value) {
                    widget.onPicked(value);
                  });
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<PickedData> pickData() async {
    LatLong center = LatLong(
        _mapController.center.latitude, _mapController.center.longitude);
    final client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_mapController.center.latitude}&lon=${_mapController.center.longitude}&zoom=18&addressdetails=1';

    final response = await client.post(Uri.parse(url));
    final decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
    String displayName = decodedResponse['display_name'];
    return PickedData(center, displayName);
  }
}

class OSMdata {
  final String displayname;
  final double lat;
  final double lon;
  OSMdata({required this.displayname, required this.lat, required this.lon});
  @override
  String toString() {
    return '$displayname, $lat, $lon';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayname == displayname;
  }

  @override
  int get hashCode => Object.hash(displayname, lat, lon);
}

class LatLong {
  final double latitude;
  final double longitude;
  LatLong(this.latitude, this.longitude);
}

class PickedData {
  final LatLong latLong;
  final String address;

  PickedData(this.latLong, this.address);
}

Future<String> getAddress(double latitude, double longitude) async {
  final client = http.Client();
  try {
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

    final response = await client.post(Uri.parse(url));
    final decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

    return decodedResponse['display_name'] ?? "";
  } catch (error, stackTrace) {
    return Future.error(error, stackTrace);
  } finally {
    client.close();
  }
}

Future<List<dynamic>> searchPhrase(String phrase) async {
  final client = http.Client();
  try {
    String url =
        'https://nominatim.openstreetmap.org/search?q=$phrase&format=json&polygon_geojson=1&addressdetails=1';
    final response = await client.post(Uri.parse(url));
    final decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decodedResponse;
  } catch (error, stackTrace) {
    return Future.error(error, stackTrace);
  } finally {
    client.close();
  }
}
