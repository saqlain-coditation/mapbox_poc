import '../base_api_repository/base_api_repository.dart';
import '../coordinates.dart';
import 'apis/mapbox_directions_api.dart';
import 'apis/mapbox_distance_api.dart';
import 'mapbox_profiles.dart';
import 'models/mapbox_direction_model.dart';
import 'models/mapbox_distance_matrix.dart';

mixin Mapbox on BaseApiRepository {
  String get accessToken;

  late final MapboxDirectionsApi _directions = MapboxDirectionsApi(this);
  late final MapboxDistanceApi _distance = MapboxDistanceApi(this);

  Future<MapboxDistanceMatrixModel?> distanceMatrix(
    List<Coordinates> coordinates, [
    MapboxProfile profile = MapboxProfile.driving,
  ]) async {
    return _distance.call(coordinates, profile, accessToken);
  }

  Future<MapboxDirectionModel?> directions(
    List<Coordinates> coordinates, [
    MapboxProfile profile = MapboxProfile.driving,
  ]) async {
    return _directions.call(coordinates, profile, accessToken);
  }

  Future<(MapboxDirectionModel, List<MapboxDirectionModel>)?> shortestPath(
    List<Coordinates> coordinates, [
    MapboxProfile profile = MapboxProfile.driving,
  ]) async {
    final distance = await distanceMatrix(coordinates, profile);
    if (distance == null) return null;

    final locations = distance.locations.values.toSet();
    final path = <MapboxDistanceModel>[];

    var source = locations.first;
    while (locations.isNotEmpty) {
      locations.remove(source);
      if (locations.isEmpty) break;

      final distances = distance.distanceMatrix[source]!;
      MapboxDistanceModel shortestPath = distances[locations.first]!;
      for (var destination in distances.entries) {
        if (!locations.contains(destination.key)) continue;

        if (destination.value.duration < shortestPath.duration) {
          shortestPath = destination.value;
        }
      }

      path.add(shortestPath);
      source = shortestPath.pointB;
    }

    final route = await Future.wait(path.map((e) async {
      final direction = (await directions(
        [e.pointA.location, e.pointB.location],
        profile,
      ))!;
      return direction.copyWith(
        route: [e.pointA.original, ...direction.route, e.pointB.original],
      );
    }));

    final fullRoute = MapboxDirectionModel(
      locations: Map.fromEntries(route.expand((e) => e.locations.entries)),
      route: route.expand((e) => e.route).toList(),
    );

    return (fullRoute, route);
  }
}
