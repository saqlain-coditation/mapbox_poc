import '../../coordinates.dart';
import 'mapbox_location_model.dart';

class MapboxDistanceMatrixModel {
  const MapboxDistanceMatrixModel({
    required this.distanceMatrix,
    required this.locations,
  });

  final Map<MapboxLocationModel, Map<MapboxLocationModel, MapboxDistanceModel>> distanceMatrix;
  final Map<Coordinates, MapboxLocationModel> locations;

  Map<String, dynamic> toMap() {
    return {
      'distanceMatrix': distanceMatrix,
      'locations': locations,
    };
  }

  static Map<MapboxLocationModel, Map<MapboxLocationModel, MapboxDistanceModel>>
      _buildDistanceMatrix(
    List<List<num?>> distances,
    List<List<num?>> durations,
    List<MapboxLocationModel> locations,
  ) {
    final matrix = <MapboxLocationModel, Map<MapboxLocationModel, MapboxDistanceModel>>{};

    for (var i = 0; i < locations.length; i++) {
      final x = locations[i];
      final row = <MapboxLocationModel, MapboxDistanceModel>{};

      for (var j = 0; j < locations.length; j++) {
        final y = locations[j];
        row[y] = MapboxDistanceModel(
          pointA: x,
          pointB: y,
          distance: (distances[i][j] ?? 0).toDouble(),
          duration: Duration(seconds: (durations[i][j] ?? 0).toInt()),
        );
      }
      matrix[x] = row;
    }

    return matrix;
  }

  factory MapboxDistanceMatrixModel.fromMap(List<Coordinates> original, Map<String, dynamic> map) {
    final locations = MapboxLocationModel.buildLocationMap(
      original,
      ((map["sources"] ?? map["destinations"]) as List).cast<Map<String, dynamic>>(),
    );
    return MapboxDistanceMatrixModel(
      distanceMatrix: _buildDistanceMatrix(
        (map["distances"] as List).cast<List>().map((e) => e.cast<num>()).toList(),
        (map["durations"] as List).cast<List>().map((e) => e.cast<num>()).toList(),
        locations.values.toList(),
      ),
      locations: locations,
    );
  }
}

class MapboxDistanceModel {
  const MapboxDistanceModel({
    required this.pointA,
    required this.pointB,
    required this.distance,
    required this.duration,
  });

  final MapboxLocationModel pointA;
  final MapboxLocationModel pointB;
  final double distance;
  final Duration duration;
}
