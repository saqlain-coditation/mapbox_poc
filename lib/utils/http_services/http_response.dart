part of 'http_services.dart';

class HttpResponse {
  factory HttpResponse(http.Response response, RawHttpRequest request) {
    return HttpResponse._internal(true, request: request, response: response);
  }

  factory HttpResponse.error(HttpError error, RawHttpRequest request) {
    return HttpResponse._internal(false, request: request, error: error);
  }

  HttpResponse._internal(
    this.success, {
    required this.request,
    this.response,
    this.error,
  }) : assert((response != null) ^ (error != null));

  final bool success;
  final RawHttpRequest request;
  final http.Response? response;
  final HttpError? error;
  late final ResponseHandler _handler = ResponseHandler(this);

  int get statusCode => response?.statusCode ?? -1;
  String? get rawBody => response?.body;
  ApiMap? get body =>
      (rawBody != null && rawBody!.isNotEmpty) ? parse(rawBody!) : null;

  ApiMap parse(String body) => json.decode(body);

  T properResponse<T>(Set<int> statusCode, T Function(ApiMap json) adapter) {
    return _handler.properResponse<T>(statusCode, adapter);
  }
}

class HttpError {
  const HttpError(this.message, {this.rawBody, this.body, this.exception});

  final String message;
  final String? rawBody;
  final ApiMap? body;
  final Exception? exception;
}

class ResponseHandler {
  const ResponseHandler(this.httpResponse);
  final HttpResponse httpResponse;

  bool get success => httpResponse.success;
  ApiMap? get body => httpResponse.body;
  HttpError? get error => httpResponse.error;
  int get statusCode => httpResponse.statusCode;

  T properResponse<T>(Set<int> statusCode, T Function(ApiMap json) adapter) {
    if (isExpectedResponse(statusCode)) {
      return adapter(body!);
    } else {
      throw notExpectedReponse;
    }
  }

  bool isExpectedResponse(Set<int> statusCode) =>
      statusCode.contains(this.statusCode);
  HttpError get notExpectedReponse {
    return success
        ? HttpError('Request Failed', rawBody: httpResponse.rawBody, body: body)
        : error!;
  }
}
