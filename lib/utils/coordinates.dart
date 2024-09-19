import 'extensions.dart';

class Coordinates {
  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  String get locationCoordinates => '$latitude,$longitude';

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coordinates &&
        other.latitude.toDoubleAsFixed(6) == latitude.toDoubleAsFixed(6) &&
        other.longitude.toDoubleAsFixed(6) == longitude.toDoubleAsFixed(6);
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'Coordinates(latitude: $latitude, longitude: $longitude)';
}
