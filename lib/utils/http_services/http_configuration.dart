import '../printing.dart';

class HttpConfiguration {
  const HttpConfiguration();

  String get exceptionSocket => "Socket Exception";
  String get exceptionTimeout => "Timeout Exception";
  String get exception => "Exception";

  void print(dynamic object) => printRemote(object);
}

extension ExtendedUri on Uri {
  Uri addQueryParameters(Map<String, dynamic> queryParameters) {
    if (queryParameters.isEmpty) return this;
    var uri = replace();

    var uriQueryParams = {...uri.queryParametersAll};
    for (var param in queryParameters.entries) {
      if (uriQueryParams.containsKey(param.key)) {
        uriQueryParams[param.key] = [...uriQueryParams[param.key]!];
        uriQueryParams[param.key]!.add(param.value);
      } else {
        if (param.value is Iterable<String>) {
          uriQueryParams[param.key] = param.value.toList();
        } else {
          uriQueryParams[param.key] = [param.value];
        }
      }
    }

    uri = uri.replace(queryParameters: uriQueryParams);
    return uri;
  }
}
