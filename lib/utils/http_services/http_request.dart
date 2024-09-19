part of 'http_services.dart';

enum HttpRequestType { get, post, put, patch, delete }

class HttpRequest {
  HttpRequest({
    required this.endpoint,
    this.body,
    this.authorization,
    Map<String, String>? headers,
    this.queryParams,
    ContentType? contentType,
    this.acceptType,
  })  : _headers = headers,
        contentType = contentType ?? ContentType.json;

  final String endpoint;
  final Map<String, String>? _headers;
  final Map<String, dynamic>? queryParams;
  final ApiMap? body;
  final String? authorization;
  final ContentType contentType;
  final ContentType? acceptType;

  Uri uri() => _createUri(endpoint, queryParams);
  Map<String, String> get headers {
    return _makeHeaders(
      contentType,
      acceptType: acceptType,
      authorization: authorization,
      additionalHeader: _headers,
    );
  }

  Map<String, String> _makeHeaders(
    ContentType contentType, {
    String? authorization,
    ContentType? acceptType,
    Map<String, String>? additionalHeader,
  }) {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: contentType.mimeType,
      HttpHeaders.acceptHeader: (acceptType ?? ContentType.json).mimeType,
      if (authorization != null && authorization.isNotEmpty)
        HttpHeaders.authorizationHeader: authorization,
    };

    if (additionalHeader != null && additionalHeader.isNotEmpty) {
      headers.addAll(additionalHeader);
    }

    return headers;
  }

  Uri _createUri(String url, [ApiMap? queryParams]) {
    var uri = Uri.parse(url);
    if (queryParams != null) uri = uri.addQueryParameters(queryParams);
    return uri;
  }

  RawHttpRequest rawRequest() =>
      RawHttpRequest(uri(), headers: headers, body: body);

  HttpRequest copyWith({
    String? endpoint,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    ApiMap? body,
    String? authorization,
    ContentType? contentType,
    ContentType? acceptType,
  }) {
    return HttpRequest(
      endpoint: endpoint ?? this.endpoint,
      headers: headers ?? _headers,
      queryParams: queryParams ?? this.queryParams,
      body: body ?? this.body,
      authorization: authorization ?? this.authorization,
      contentType: contentType ?? this.contentType,
      acceptType: acceptType ?? this.acceptType,
    );
  }
}

class RawHttpRequest {
  const RawHttpRequest(
    this.uri, {
    this.headers,
    this.body,
  });

  final Uri uri;
  final Map<String, String>? headers;
  final ApiMap? body;
}
