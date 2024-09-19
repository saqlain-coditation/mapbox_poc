import 'package:testing/utils/extensions.dart';

import '../../coordinates.dart';

class MapboxLocationModel {
  const MapboxLocationModel({
    required this.name,
    required this.location,
    required this.original,
    required this.adjustments,
  });

  final String name;
  final Coordinates location;
  final Coordinates original;
  final double adjustments;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': [location.longitude, location.latitude],
      'distance': adjustments,
    };
  }

  static Map<Coordinates, MapboxLocationModel> buildLocationMap(
    List<Coordinates> original,
    List<Map<String, dynamic>> sources,
  ) {
    return Map.fromEntries(sources.mapIndexed((i, s) {
      final location = MapboxLocationModel.fromMap(original[i], s);
      return MapEntry(location.location, location);
    }));
  }

  factory MapboxLocationModel.fromMap(Coordinates original, Map<String, dynamic> map) {
    return MapboxLocationModel(
      name: map['name'] ?? '',
      location: Coordinates(
        longitude: map["location"][0],
        latitude: map["location"][1],
      ),
      original: original,
      adjustments: map['distance']?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapboxLocationModel && other.location == location;
  }

  @override
  int get hashCode => location.hashCode;
}
