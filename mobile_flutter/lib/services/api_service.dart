import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$path')
          .replace(queryParameters: queryParams);

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: _headers)
              .timeout(AppConfig.requestTimeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
              .timeout(AppConfig.requestTimeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
              .timeout(AppConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: _headers)
              .timeout(AppConfig.requestTimeout);
          break;
        default:
          throw ApiException('Unsupported method: $method');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      throw ApiException(
        data['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('Network error: Could not connect to server');
    } on http.ClientException {
      throw ApiException('Network error: Connection failed');
    } on FormatException {
      throw ApiException('Invalid response from server');
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) =>
      _request('GET', path, queryParams: queryParams);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) =>
      _request('PUT', path, body: body);

  Future<Map<String, dynamic>> delete(String path) =>
      _request('DELETE', path);
}
