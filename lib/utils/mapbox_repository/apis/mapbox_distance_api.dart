import '../../base_api_repository/base_api.dart';
import '../../coordinates.dart';
import '../../http_services/http_services.dart';
import '../mapbox_profiles.dart';
import '../models/mapbox_distance_matrix.dart';

class MapboxDistanceApi extends BaseApi {
  const MapboxDistanceApi(super.repository);
  Future<MapboxDistanceMatrixModel?> call(
    List<Coordinates> coordinates,
    MapboxProfile profile,
    String token,
  ) async {
    var res = await raw(coordinates, profile, token);
    return properResponse<MapboxDistanceMatrixModel>(
      res,
      statusCode: {200},
      parser: (json) => MapboxDistanceMatrixModel.fromMap(coordinates, json),
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
        "https://api.mapbox.com/directions-matrix/v1/${profile.apiKey}/$coordinatatesString",
        queryParams: {"access_token": token, "annotations": "distance,duration"},
      ),
    );
  }
}
