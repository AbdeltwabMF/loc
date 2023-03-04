import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loc/data/models/point.dart';

class OsmApis {
  static const String osmBaseUrl = 'https://nominatim.openstreetmap.org';
  late http.Client _client;

  OsmApis() {
    _client = http.Client();
  }

  Future<dynamic> reverse(Point position) async {
    try {
      String reverseUrl =
          '$osmBaseUrl/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=16&addressdetails=1';
      final response = await _client.get(Uri.parse(reverseUrl));

      if (response.statusCode != 200) {
        return Future.error(response.statusCode);
      }

      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (error, stackTrace) {
      return Future.error(error, stackTrace);
    } finally {
      _client.close();
    }
  }

  Future<List<dynamic>> search(String searchValue) async {
    try {
      String searchUrl =
          '$osmBaseUrl/search?q=$searchValue&format=json&polygon_geojson=1&addressdetails=1';
      final response = await _client.get(Uri.parse(searchUrl));

      if (response.statusCode != 200) {
        return Future.error(response.statusCode);
      }

      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (error, stackTrace) {
      return Future.error(error, stackTrace);
    } finally {
      _client.close();
    }
  }
}
