part of 'http_services.dart';

abstract class HttpClient {
  Duration get timeout => const Duration(minutes: 2);

  http.Client? get _client;

  Future<http.Response> getRaw(RawHttpRequest request) {
    Future<http.Response> res;
    if (_client != null) {
      res = _client!.get(request.uri, headers: request.headers);
    } else {
      res = http.get(request.uri, headers: request.headers);
    }
    return _responseWrapper(res);
  }

  Future<http.Response> postRaw(RawHttpRequest request) {
    Future<http.Response> res;
    if (_client != null) {
      res = _client!.post(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    } else {
      res = http.post(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    }
    return _responseWrapper(res);
  }

  Future<http.Response> putRaw(RawHttpRequest request) {
    Future<http.Response> res;
    if (_client != null) {
      res = _client!.put(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    } else {
      res = http.put(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    }
    return _responseWrapper(res);
  }

  Future<http.Response> patchRaw(RawHttpRequest request) {
    Future<http.Response> res;
    if (_client != null) {
      res = _client!.patch(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    } else {
      res = http.patch(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    }
    return _responseWrapper(res);
  }

  Future<http.Response> deleteRaw(RawHttpRequest request) {
    Future<http.Response> res;
    if (_client != null) {
      res = _client!.delete(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    } else {
      res = http.delete(
        request.uri,
        headers: request.headers,
        body: json.encode(request.body),
      );
    }
    return _responseWrapper(res);
  }

  Future<http.StreamedResponse> formDataRequestRaw(
    HttpRequestType requestType,
    RawHttpRequest request,
    MediaType? Function(String key, dynamic data) typeResolver,
  ) async {
    ApiMap formData = await _fileConversion(request.body ?? {}, typeResolver);
    http.MultipartRequest req =
        http.MultipartRequest(requestType.name.toUpperCase(), request.uri)
          ..fields.addAll(formData['fields'])
          ..files.addAll(formData['files'])
          ..headers.addAll(request.headers ?? {});

    Future<http.StreamedResponse> res;
    logFormDataRequest(req);
    if (_client != null) {
      res = _client!.send(req);
    } else {
      res = req.send();
    }

    res = _responseWrapper(res);
    return res;
  }

  Future<http.Response> requestRaw({
    required HttpRequestType requestType,
    required RawHttpRequest request,
    Duration? timeout,
  }) async {
    var sres = await streamedRequestRaw(
      requestType: requestType,
      request: request,
      timeout: timeout,
    );
    return _convertStreamed(sres);
  }

  Future<http.StreamedResponse> streamedRequestRaw({
    required HttpRequestType requestType,
    required RawHttpRequest request,
    Duration? timeout,
  }) async {
    var req = http.Request(requestType.name.toUpperCase(), request.uri)
      ..headers.addAll(request.headers ?? {})
      ..body = json.encode(request.body);

    Future<http.StreamedResponse> res;
    if (_client != null) {
      res = _client!.send(req);
    } else {
      res = req.send();
    }

    res = _responseWrapper(res);
    return res;
  }

  Future<T> _responseWrapper<T extends http.BaseResponse>(Future<T> response) {
    return response.timeout(timeout);
  }

  Future<http.Response> _convertStreamed(http.StreamedResponse response) {
    var res = http.Response.fromStream(response);
    res = _responseWrapper(res);
    return res;
  }

  Future<ApiMap> _fileConversion(
    ApiMap body,
    MediaType? Function(String key, dynamic data) typeResolver,
  ) async {
    final fields = <String, String>{};
    final files = <http.MultipartFile>[];

    Future<void> processData(String name, dynamic data, MediaType? type) async {
      Future<http.MultipartFile> fromPath(String path) {
        return http.MultipartFile.fromPath(
          name,
          data.path,
          contentType: type,
        );
      }

      switch (data) {
        case File():
          final file = await fromPath(data.path);
          files.add(file);
          break;

        case XFile():
          final file = await fromPath(data.path);
          files.add(file);
          break;

        case Iterable():
          throw UnsupportedError('Collections not supported');

        default:
          fields[name] = data.toString();
      }
    }

    for (var entry in body.entries) {
      final name = entry.key;
      final data = entry.value;
      final type = typeResolver(name, data);
      await processData(name, data, type);
    }

    return {'fields': fields, 'files': files};
  }

  void logFormDataRequest(http.MultipartRequest request) {
    final log = {
      'URL': request.url,
      'METHOD': request.method,
      'HEADERS': request.headers,
      'BODY': {
        'fields': request.fields,
        'files': request.files
            .map((e) => {
                  'field': e.field,
                  'filename': e.filename,
                  'contentType': e.contentType,
                  'length': e.length,
                })
            .toList(),
      },
    };
    logBase(log);
  }

  void logBase(Map<String, dynamic> log);
}
