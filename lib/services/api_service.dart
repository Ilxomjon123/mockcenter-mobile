import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.mockcenter.uz/api';
  static String get examBaseUrl => dotenv.env['EXAM_BASE_URL'] ?? 'https://exam.mockcenter.uz';
  static String get telegramBotUsername => dotenv.env['TELEGRAM_BOT_USERNAME'] ?? 'MockCenterBot';

  final StorageService _storage;

  ApiService(this._storage);

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = false}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] as String? ?? body['error'] as String? ?? 'An error occurred',
      errors: body['errors'] as Map<String, dynamic>?,
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}
