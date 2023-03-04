import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/osm_apis.dart';

class Maps {
  late OsmApis _osmApis;

  Maps() {
    _osmApis = OsmApis();
  }

  Future<Place> getLocationInfo(Point position) async {
    final location = await _osmApis.reverse(position).onError(
          (error, stackTrace) => Future.error(error!, stackTrace),
        );
    return Place.fromJson(location as Map<String, dynamic>);
  }

  Future<List<Place>> searchLocation(String locationName) async {
    final location = await _osmApis.search(locationName).onError(
          (error, stackTrace) => Future.error(error!, stackTrace),
        );
    return location.map((e) => Place.fromJson(e)).toList();
  }
}
