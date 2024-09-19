import '../extensions.dart';

enum MapboxProfile {
  driving,
  walking,
  cycling,
  drivingTraffic;

  String get apiKey => "mapbox/${name.convertCase("-")}";
}
