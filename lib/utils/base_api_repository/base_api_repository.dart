import 'package:testing/_interfaces/base_repository.dart';

import '../http_services/http_services.dart';

class BaseApiRepository with ApiInterceptors implements BaseRepository {
  BaseApiRepository(this.httpService);
  final HttpServices httpService;
  //----------------------------------------------------------------------------
}

mixin ApiInterceptors {
  Map<String, dynamic> inputInterceptor(Map<String, dynamic> input) => input;
  Map<String, dynamic> outputInterceptor(Map<String, dynamic> output) => output;
}
