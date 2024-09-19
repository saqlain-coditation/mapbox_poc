import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'http_configuration.dart';

part 'http_client.dart';
part 'http_request.dart';
part 'http_response.dart';

typedef ApiMap = Map<String, dynamic>;

class HttpServices extends HttpClient {
  HttpServices({
    HttpConfiguration? config,
    http.Client? client,
    this.timeout = const Duration(minutes: 2),
  })  : config = config ?? const HttpConfiguration(),
        _client = client;

  final HttpConfiguration config;

  @override
  http.Client? _client;

  @override
  final Duration timeout;

  void initClient([http.Client? client]) {
    _client?.close();
    _client = client ?? http.Client();
  }

  void dispose() {
    _client?.close();
    _client = null;
  }

  Future<HttpResponse> get(HttpRequest request) {
    return _finalize(HttpRequestType.get, request, getRaw);
  }

  Future<HttpResponse> post(HttpRequest request) {
    return _finalize(HttpRequestType.post, request, postRaw);
  }

  Future<HttpResponse> put(HttpRequest request) {
    return _finalize(HttpRequestType.put, request, putRaw);
  }

  Future<HttpResponse> patch(HttpRequest request) {
    return _finalize(HttpRequestType.patch, request, patchRaw);
  }

  Future<HttpResponse> delete(HttpRequest request) {
    return _finalize(HttpRequestType.delete, request, deleteRaw);
  }

  Future<HttpResponse> formDataRequest(
    HttpRequestType requestType,
    HttpRequest request, {
    MediaType? Function(String key, dynamic data)? typeResolver,
  }) async {
    return _finalize(
      requestType,
      request,
      (req) async {
        var streamedRes = await formDataRequestRaw(
          requestType,
          req,
          typeResolver ?? (key, data) => null,
        );
        return _convertStreamed(streamedRes);
      },
    );
  }

  Future<HttpResponse> request({
    required HttpRequestType requestType,
    required HttpRequest request,
  }) async {
    return _finalize(
      requestType,
      request,
      (req) => requestRaw(requestType: requestType, request: req),
    );
  }

  Future<HttpResponse> _finalize(
    HttpRequestType method,
    HttpRequest request,
    Future<http.Response> Function(RawHttpRequest request) httpCall,
  ) async {
    final rawRequest = request.rawRequest();
    logRequest(method, rawRequest);
    final response = await _catchErrors(rawRequest, () async {
      final rawResponse = await httpCall(rawRequest);
      final response = HttpResponse(rawResponse, rawRequest);
      return response;
    });
    logResponse(response);
    return response;
  }

  Future<HttpResponse> _catchErrors(
    RawHttpRequest request,
    Future<HttpResponse> Function() httpCall,
  ) async {
    HttpError error;
    try {
      return await httpCall();
    } on SocketException catch (e) {
      error = HttpError(config.exceptionSocket, exception: e);
    } on TimeoutException catch (e) {
      error = HttpError(config.exceptionTimeout, exception: e);
    } on http.ClientException catch (e) {
      error = HttpError(config.exception, exception: e);
    } on Exception catch (e) {
      error = HttpError(config.exception, exception: e);
    }
    return HttpResponse.error(error, request);
  }

  void logRequest(HttpRequestType method, RawHttpRequest request) {
    final log = {
      'URL': request.uri.toString(),
      'METHOD': method.name,
      if (request.headers != null) 'HEADERS': request.headers,
      if (request.body != null) 'BODY': request.body,
    };
    logBase(log);
  }

  void logResponse(HttpResponse response) {
    Object? body;
    try {
      body = response.body;
    } catch (e) {
      body = response.rawBody;
    }

    final log = {
      'URL': response.request.uri.toString(),
      'STATUS CODE': response.statusCode,
      'RESPONSE': body,
    };
    logBase(log);
  }

  @override
  void logBase(Map<String, dynamic> log) {
    config.print('_' * 80);
    final now = DateTime.now();
    final finalLog = {
      'TIMESTAMP': '${now.hour} : ${now.minute} : ${now.second}',
      ...log,
    };
    config.print(finalLog);
    config.print('_' * 80);
  }
}
