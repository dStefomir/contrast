import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path_lib;

/// Proxy for the restfull apis
class Proxy {
  /// Url of the back-end
  // static const String _host = 'https://www.dstefomir.eu/api';
  static const String _host = 'http://127.0.0.1:8080';
  // static const String host = 'http://192.168.100.8:8080';

  /// JWT token
  final String? token;
  /// Handler function for the token expiration
  final Function() onInvalidToken;

  const Proxy(this.token, {required this.onInvalidToken});

  /// Getter for the core url
  get host => _host;

  /// Construct the url for the restful apis
  static String _makeUrl(String path, {List<MapEntry>? query}) {
    final url = !_host.endsWith('/') && !path.startsWith('/')
        ? '$_host/$path'
        : _host + path;
    query = query ?? [];
    final params = query.map((e) => '${e.key}=${e.value}');
    return params.isNotEmpty ? '$url?${params.join('&')}' : url;
  }

  /// Appending the headers to the restful apis
  Map<String, String> _prepareHeaders(Map<String, String>? headers) {
    final Map<String, String> result = {
      'Content-Type': 'application/json',
    };

    if (headers != null) {
      result.addAll(headers);
    }
    if (token != null && token!.isNotEmpty) {
      result['Authorization'] = 'Bearer $token';
    }

    return result;
  }

  /// Parsing the response from the restful apis
  String? _prepareBody(Map? data) => data == null ? null : jsonEncode(data);

  /// GET request
  Future<dynamic> get(String path, {List<MapEntry>? query, Map<String, String>? extraHeaders}) async {
    final String url = _makeUrl(path, query: query);
    final Map<String, String> headers = _prepareHeaders(extraHeaders);
    try {
      var server = Uri.parse(Uri.encodeFull(url));
      final response = await http.get(server, headers: headers);

      return _extract(response);
    } on SocketException {
      throw NetworkException("Network Error");
    }
  }

  /// POST request
  Future<dynamic> post(String path, {Map? data, Map<String, String>? extraHeaders}) async {
    final String url = _makeUrl(path);
    final Map<String, String> headers = _prepareHeaders(extraHeaders);
    final String? body = _prepareBody(data);
    try {
      var server = Uri.parse(Uri.encodeFull(url));
      final response = await http.post(server, body: body, headers: headers);

      try {
        return _extract(response);
      } catch (e) {
        return response;
      }
    } on SocketException {
      throw NetworkException("Network Error");
    }
  }

  /// POST a file request
  Future<dynamic> postFile(String path, {required File file}) async {
    final String url = _makeUrl(path);
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile(
          'file', file.readAsBytes().asStream(), file.lengthSync(),
          filename: path_lib.basename(file.path)));
    try {
      final response = await request.send();
      return jsonDecode(await response.stream.bytesToString());
    } on SocketException {
      throw NetworkException("Network Error");
    }
  }

  /// PUT request
  Future<dynamic> put(String path, {Map? data, Map<String, String>? extraHeaders}) async {
    final String url = _makeUrl(path);
    final Map<String, String> headers = _prepareHeaders(extraHeaders);
    final String? body = _prepareBody(data);
    try {
      var server = Uri.parse(Uri.encodeFull(url));
      final response = await http.put(server, body: body, headers: headers);
      return _extract(response);
    } on SocketException {
      throw NetworkException("Network Error");
    }
  }

  /// DELETE request
  Future<dynamic> delete(String path, {Map<String, String>? extraHeaders}) async {
    final String url = _makeUrl(path);
    final Map<String, String> headers = _prepareHeaders(extraHeaders);
    try {
      var server = Uri.parse(Uri.encodeFull(url));
      final response = await http.delete(server, headers: headers);

      return _extract(response);
    } on SocketException {
      throw NetworkException("Network Error");
    }
  }

  /// Extracting the response from the restful apis
  dynamic _extract(http.Response response) {
    switch (response.statusCode) {
      case 200:
        if (response.headers['content-type'] == "image/jpeg") {
          return response.bodyBytes;
        }
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      case 201:
        return jsonDecode(response.body);
      case 204:
        return;
      case 400:
        final error = jsonDecode(response.body);
        if (error['type'] == 'conresma.auth.exceptions.TokenExpired' ||
            error['type'] == 'conresma.auth.exceptions.InvalidToken') {
          onInvalidToken();
        }
        throw BadRequestException(error["type"]);
      case 401:
        final error = jsonDecode(response.body);
        if (error['type'] == 'conresma.auth.exceptions.TokenExpired' ||
            error['type'] == 'conresma.auth.exceptions.InvalidToken') {
          onInvalidToken();
        }
        throw UnauthorisedException(error["type"]);
      case 403:
        final error = jsonDecode(response.body);
        throw UnauthorisedException(error["type"]);
      case 404:
        final error = jsonDecode(response.body);
        throw ResourceNotFoundException(error["type"]);
      case 409:
        final error = jsonDecode(response.body);
        throw FetchDataException(error["type"]);
      case 422:
        final error = jsonDecode(response.body);
        throw ValidationException(error["type"]);
      case 500:
      default:
        final error = jsonDecode(response.body);
        throw FetchDataException(error["type"]);
    }
  }
}

/// General exception handler class
class ServerException implements Exception {
  /// Message of the exception
  final String? _message;
  /// Prefix of the exception
  final String? _prefix;

  ServerException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix: $_message";
  }
}

/// Fetch exception handler
class FetchDataException extends ServerException {
  FetchDataException([String? message]) : super(message, "Fetch Data Exception");
}

/// Bad request exception handler
class BadRequestException extends ServerException {
  BadRequestException([message]) : super(message, "Invalid Request");
}

/// Unauthorised exception handler
class UnauthorisedException extends ServerException {
  UnauthorisedException([message]) : super(message, "Unauthorised");
}

/// Resource not found exception handler
class ResourceNotFoundException extends ServerException {
  ResourceNotFoundException([message]) : super(message, "Resource Not Found");
}

/// Validation exception handler
class ValidationException extends ServerException {
  ValidationException([message]) : super(message, "Validation");
}

/// Invalid input exception handler
class InvalidInputException extends ServerException {
  InvalidInputException([String? message]) : super(message, "Invalid Input");
}

/// No network exception handler
class NetworkException extends ServerException {
  NetworkException([String? message]) : super(message, "Network");
}
