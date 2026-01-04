import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';
import 'api_enes.dart';
import 'api_exception.dart';

/// Singleton API Service for handling all HTTP requests
/// Automatically manages authentication tokens from local storage
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = ApiEnv.baseUrl;
  String? _cachedToken;

  /// 🔥 NEW: Initialize token from storage
  Future<void> initializeToken() async {
    _cachedToken = AppLocalData.getString(LocalDataKey.accessToken);
    debugPrint('🔑 Token initialized: ${_cachedToken != null ? "Found" : "Not found"}');
  }

  /// 🔥 NEW: Set token (call this after login)
  void setToken(String token) {
    _cachedToken = token;
    debugPrint('🔑 Token set in ApiService');
  }

  /// 🔥 NEW: Clear token (call this on logout)
  void clearToken() {
    _cachedToken = null;
    debugPrint('🔑 Token cleared from ApiService');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Get current token
  String? get currentToken => _cachedToken;

  /// Get headers with authorization
  Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_cachedToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Log API request/response
  void _logApi({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    http.Response? response,
  }) {
    const border = '┌────────────────────────────────────────────────────────';
    const divider = '├────────────────────────────────────────────────────────┤';
    const bottom = '└────────────────────────────────────────────────────────┘';

    debugPrint('\n$border');
    debugPrint('│ 🔹 $method REQUEST');
    debugPrint(divider);
    debugPrint('│ URL: $url');

    if (headers != null && headers.isNotEmpty) {
      final maskedHeaders = Map<String, String>.from(headers);
      if (maskedHeaders.containsKey('Authorization')) {
        final token = maskedHeaders['Authorization']!;
        maskedHeaders['Authorization'] =
        token.length > 20 ? '${token.substring(0, 20)}...[MASKED]' : '[MASKED]';
      }
      debugPrint('│ Headers: ${jsonEncode(maskedHeaders)}');
    }

    if (body != null) {
      final bodyStr = jsonEncode(body);
      debugPrint('│ Body: ${bodyStr.length > 200 ? '${bodyStr.substring(0, 200)}...' : bodyStr}');
    }

    if (response != null) {
      debugPrint(divider);
      debugPrint('│ 🔸 RESPONSE');
      debugPrint('│ Status: ${response.statusCode}');

      try {
        final formatted = const JsonEncoder.withIndent('  ').convert(
          json.decode(response.body),
        );
        for (var line in formatted.split('\n').take(20)) {
          debugPrint('│ $line');
        }
      } catch (_) {
        final body = response.body;
        debugPrint('│ ${body.length > 200 ? '${body.substring(0, 200)}...' : body}');
      }
    }

    debugPrint(bottom);
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('Invalid JSON response');
      }
    } else {
      String errorMessage = 'Error ${response.statusCode}';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ??
            errorBody['error'] ??
            errorBody['msg'] ??
            errorMessage;
      } catch (_) {
        errorMessage = 'Error ${response.statusCode}: ${response.body}';
      }

      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  /// GET request
  Future<dynamic> get(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    // 🔥 Ensure token is loaded before making request
    if (_cachedToken == null) {
      await initializeToken();
    }

    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(customHeaders: headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _logApi(
        method: 'GET',
        url: url,
        headers: requestHeaders,
        response: response,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// POST request
  Future<dynamic> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    // 🔥 Ensure token is loaded before making request
    if (_cachedToken == null) {
      await initializeToken();
    }

    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(customHeaders: headers);
    debugPrint("$requestHeaders");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );

      _logApi(
        method: 'POST',
        url: url,
        headers: requestHeaders,
        body: body,
        response: response,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
      }) async {
    // 🔥 Ensure token is loaded before making request
    if (_cachedToken == null) {
      await initializeToken();
    }

    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(customHeaders: headers);

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );

      _logApi(
        method: 'PUT',
        url: url,
        headers: requestHeaders,
        body: body,
        response: response,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    // 🔥 Ensure token is loaded before making request
    if (_cachedToken == null) {
      await initializeToken();
    }

    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(customHeaders: headers);

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _logApi(
        method: 'DELETE',
        url: url,
        headers: requestHeaders,
        response: response,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}