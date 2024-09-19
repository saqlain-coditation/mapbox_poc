import '../../base_api_repository/base_api.dart';
import '../../coordinates.dart';
import '../../http_services/http_services.dart';
import '../mapbox_profiles.dart';
import '../models/mapbox_direction_model.dart';

class MapboxDirectionsApi extends BaseApi {
  const MapboxDirectionsApi(super.repository);

  Future<MapboxDirectionModel?> call(
    List<Coordinates> coordinates,
    MapboxProfile profile,
    String token,
  ) async {
    var res = await raw(coordinates, profile, token);
    return properResponse<MapboxDirectionModel>(
      res,
      statusCode: {200},
      parser: (json) => MapboxDirectionModel.fromMap(coordinates, json),
    );
  }

  Future<HttpResponse> raw(
    List<Coordinates> coordinates,
    MapboxProfile profile,
    String token,
  ) async {
    var coordinatatesString = coordinates.map((e) => "${e.longitude},${e.latitude}").join(";");
    return await http.get(
      createRawRequest(
        'https://api.mapbox.com/directions/v5/${profile.apiKey}/$coordinatatesString',
        queryParams: {
          "access_token": token,
          "waypoints_per_route": true.toString(),
          "geometries": "geojson"
        },
      ),
    );
  }
}
