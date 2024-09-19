import 'package:testing/main.dart';
import 'package:testing/utils/base_api_repository/base_api_repository.dart';
import 'package:testing/utils/http_services/http_services.dart';
import 'package:testing/utils/mapbox_repository/mapbox_repository.dart';

class NavigationRepository extends BaseApiRepository with Mapbox {
  NavigationRepository._internal(super.httpService);
  static final NavigationRepository _singleton = NavigationRepository._internal(HttpServices());
  factory NavigationRepository() => _singleton;

  @override
  String get accessToken => mapboxToken;
}
