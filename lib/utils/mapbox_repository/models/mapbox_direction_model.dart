import 'package:flutter/widgets.dart';

import '../../coordinates.dart';
import 'mapbox_location_model.dart';

class MapboxDirectionModel {
  const MapboxDirectionModel({
    this.id,
    required this.locations,
    required this.route,
  });

  final String? id;
  final Map<Coordinates, MapboxLocationModel> locations;
  final List<Coordinates> route;

  Map<String, dynamic> toMap() {
    return {
      "uuid": id,
      "routes": [
        {
          "waypoints": locations.values.map((e) => e.toMap()).toList(),
          "geometry": {
            "coordinates": route.map((e) => [e.longitude, e.latitude]).toList(),
            "type": "LineString",
          },
        }
      ],
    };
  }

  factory MapboxDirectionModel.fromMap(List<Coordinates> original, Map<String, dynamic> map) {
    final route = map["routes"][0];
    return MapboxDirectionModel(
      id: map["uuid"],
      locations: MapboxLocationModel.buildLocationMap(
        original,
        (route["waypoints"] as List).cast<Map<String, dynamic>>(),
      ),
      route: List<Coordinates>.from(
        route["geometry"]["coordinates"]?.map(
          (x) => Coordinates(longitude: x[0], latitude: x[1]),
        ),
      ),
    );
  }

  MapboxDirectionModel copyWith({
    ValueGetter<String?>? id,
    Map<Coordinates, MapboxLocationModel>? locations,
    List<Coordinates>? route,
  }) {
    return MapboxDirectionModel(
      id: id != null ? id() : this.id,
      locations: locations ?? this.locations,
      route: route ?? this.route,
    );
  }
}
