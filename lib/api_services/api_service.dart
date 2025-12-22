import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../res/database/local_data_key.dart';
import 'api_enes.dart';
import 'api_exception.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = ApiEnv.baseUrl;
  String? _bearerToken;

  // Initialize and load token from storage
  Future<void> init() async {
    await _loadToken();
  }

  // Load token from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    // FIX: Use the actual enum key value, not toString()
    final tokenKey = LocalDataKey.accessToken.name; // or use the actual key string
    _bearerToken = prefs.getString(tokenKey);

    debugPrint('🔑 Token Key: $tokenKey');
    debugPrint('🔑 _bearerToken: ${_bearerToken != null ? "✅ Token exists (${_bearerToken!.substring(0, 20)}...)" : "❌ No token found"}');

    if (_bearerToken != null) {
      debugPrint('✅ Token loaded from storage');
    } else {
      debugPrint('⚠️ No token found in storage');
    }
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    _bearerToken = token;
    final prefs = await SharedPreferences.getInstance();
    // FIX: Use the actual enum key value, not toString()
    final tokenKey = LocalDataKey.accessToken.name;
    await prefs.setString(tokenKey, token);
    debugPrint('✅ Token saved to storage: ${token.substring(0, 20)}...');
  }

  // Clear token (for logout)
  Future<void> clearToken() async {
    _bearerToken = null;
    final prefs = await SharedPreferences.getInstance();
    final tokenKey = LocalDataKey.accessToken.name;
    await prefs.remove(tokenKey);
    debugPrint('🗑️ Token cleared');
  }

  bool get isAuthenticated => _bearerToken != null;

  // Get current token (for debugging)
  String? get currentToken => _bearerToken;

  // FIX: Updated _getHeaders to properly merge headers
  Future<Map<String, String>> _getHeadersAsync(Map<String, String>? customHeaders) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // If token is not in memory, try to load from SharedPreferences
    if (_bearerToken == null) {
      await _loadToken();
    }

    // Add Authorization first if token exists
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    } else {
      debugPrint('⚠️ WARNING: No bearer token available for request');
    }

    // Then add custom headers (they can override if needed)
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // Synchronous version for backward compatibility
  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Add Authorization first if token exists
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    } else {
      debugPrint('⚠️ WARNING: No bearer token available for request');
    }

    // Then add custom headers (they can override if needed)
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // Add method to manually set token
  void setToken(String token) {
    _bearerToken = token;
    debugPrint('✅ Token manually set: ${token.substring(0, 20)}...');
  }

  // Add method to get token from storage synchronously
  Future<String?> getStoredToken() async {
    if (_bearerToken == null) {
      await _loadToken();
    }
    return _bearerToken;
  }

  // 🟩 Helper to print nice bordered API logs
  void _printApiLog({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic requestBody,
    http.Response? response,
  }) {
    const borderTop =
        '╔═══════════════════════════════════════════════════════════════╗';
    const borderMid =
        '╠───────────────────────────────────────────────────────────────╣';
    const borderBottom =
        '╚═══════════════════════════════════════════════════════════════╝';

    debugPrint('\n$borderTop');
    debugPrint('║ 🔹 API REQUEST');
    debugPrint(borderMid);
    debugPrint('║ METHOD : $method');
    debugPrint('║ URL    : $url');
    if (headers != null && headers.isNotEmpty) {
      // Mask the Authorization token for security
      final maskedHeaders = Map<String, String>.from(headers);
      if (maskedHeaders.containsKey('Authorization')) {
        final token = maskedHeaders['Authorization']!;
        maskedHeaders['Authorization'] = token.length > 20
            ? '${token.substring(0, 20)}...[MASKED]'
            : '[MASKED]';
      }
      debugPrint('║ HEADERS: ${jsonEncode(maskedHeaders)}');
    }
    if (requestBody != null) {
      final bodyStr = jsonEncode(requestBody);
      if (bodyStr.length > 500) {
        debugPrint('║ BODY   : ${bodyStr.substring(0, 500)}...[TRUNCATED]');
      } else {
        debugPrint('║ BODY   : $bodyStr');
      }
    }

    if (response != null) {
      debugPrint(borderMid);
      debugPrint('║ 🔸 API RESPONSE');
      debugPrint(borderMid);
      debugPrint('║ STATUS : ${response.statusCode}');
      try {
        final formatted = const JsonEncoder.withIndent(
          '  ',
        ).convert(json.decode(response.body));
        for (var line in formatted.split('\n')) {
          debugPrint('║ $line');
        }
      } catch (_) {
        debugPrint('║ ${response.body}');
      }
    }

    debugPrint(borderBottom);
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    await _loadToken();
    final url = '$baseUrl$endpoint';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(headers),
      );
      _printApiLog(
        method: 'GET',
        url: url,
        headers: _getHeaders(headers),
        response: response,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    await _loadToken();
    final url = '$baseUrl$endpoint';

    // Use _getHeaders to ensure Authorization token is included
    final requestHeaders = _getHeaders(headers);

    try {
      debugPrint("📤 POST Body: ${json.encode(body)}");
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(body),
      );

      // Save token if it's a login request
      if (isLogin &&
          (response.statusCode >= 200 && response.statusCode < 300)) {
        final token = response.headers['authorization'] ??
            response.headers['Authorization'] ??
            response.headers['token'];
        if (token != null) {
          final cleanToken =
          token.startsWith('Bearer ') ? token.substring(7) : token;
          await _saveToken(cleanToken);
        } else {
          debugPrint('⚠️ Warning: No token found in response headers');
        }
      }

      _printApiLog(
        method: 'POST',
        url: url,
        headers: requestHeaders,
        requestBody: body,
        response: response,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> put(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
      }) async {
    final url = '$baseUrl$endpoint';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(headers),
        body: json.encode(body),
      );
      _printApiLog(
        method: 'PUT',
        url: url,
        headers: _getHeaders(headers),
        requestBody: body,
        response: response,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    final url = '$baseUrl$endpoint';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(headers),
      );
      _printApiLog(
        method: 'DELETE',
        url: url,
        headers: _getHeaders(headers),
        response: response,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('Invalid JSON response');
      }
    } else {
      // Extract error message from response body if available
      String errorMessage = 'Error ${response.statusCode}';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ??
            errorBody['error'] ??
            errorBody['msg'] ??
            'Error ${response.statusCode}: ${response.body}';
      } catch (_) {
        errorMessage = 'Error ${response.statusCode}: ${response.body}';
      }

      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}