import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';
import 'api_enes.dart';
import 'api_exception.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = ApiEnv.baseUrl;
  String? _bearerToken;
  bool _tokenLoaded = false;

  // Initialize and load token from storage
  Future<void> init() async {
    await _loadToken();
  }

  /// Load token from AppLocalData (your local storage)
  Future<void> _loadToken() async {
    if (_tokenLoaded) return; // Prevent multiple loads

    try {
      // Get token from your local storage using AppLocalData
      final token = await AppLocalData.getString(LocalDataKey.accessToken);

      if (token != null && token.isNotEmpty) {
        _bearerToken = token;
        debugPrint('✅ Token loaded from local storage: ${token.substring(0, 20)}...');
      } else {
        _bearerToken = null;
        debugPrint('⚠️ No token found in local storage');
      }

      _tokenLoaded = true;
    } catch (e) {
      debugPrint('❌ Error loading token: $e');
      _bearerToken = null;
      _tokenLoaded = true;
    }
  }

  /// Save token to local storage (when user logs in)
  Future<void> saveToken(String token) async {
    try {
      _bearerToken = token;
      await AppLocalData.setString(LocalDataKey.accessToken, token);
      debugPrint('✅ Token saved to local storage: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  /// Clear token (for logout)
  Future<void> clearToken() async {
    try {
      _bearerToken = null;
      await AppLocalData.remove(LocalDataKey.accessToken);
      _tokenLoaded = false;
      debugPrint('🗑️ Token cleared');
    } catch (e) {
      debugPrint('❌ Error clearing token: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _bearerToken != null && _bearerToken!.isNotEmpty;

  /// Get current token (for debugging)
  String? get currentToken => _bearerToken;

  /// Get headers with authorization token
  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add Authorization header if token exists
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
      debugPrint('🔐 Authorization header added');
    } else {
      debugPrint('⚠️ WARNING: No bearer token available for request');
    }

    // Add custom headers (they can override defaults if needed)
    if (customHeaders != null && customHeaders.isNotEmpty) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Pretty print API logs with borders
  void _printApiLog({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic requestBody,
    http.Response? response,
  }) {
    const borderTop =
        '┌──────────────────────────────────────────────────────────────────────┐';
    const borderMid =
        '├──────────────────────────────────────────────────────────────────────┤';
    const borderBottom =
        '└──────────────────────────────────────────────────────────────────────┘';

    debugPrint('\n$borderTop');
    debugPrint('│ 🔹 API REQUEST');
    debugPrint(borderMid);
    debugPrint('│ METHOD : $method');
    debugPrint('│ URL    : $url');

    if (headers != null && headers.isNotEmpty) {
      final maskedHeaders = Map<String, String>.from(headers);
      // Mask the Authorization token for security
      if (maskedHeaders.containsKey('Authorization')) {
        final token = maskedHeaders['Authorization']!;
        maskedHeaders['Authorization'] = token.length > 20
            ? '${token.substring(0, 20)}...[MASKED]'
            : '[MASKED]';
      }
      debugPrint('│ HEADERS: ${jsonEncode(maskedHeaders)}');
    }

    if (requestBody != null) {
      final bodyStr = jsonEncode(requestBody);
      if (bodyStr.length > 500) {
        debugPrint('│ BODY   : ${bodyStr.substring(0, 500)}...[TRUNCATED]');
      } else {
        debugPrint('│ BODY   : $bodyStr');
      }
    }

    if (response != null) {
      debugPrint(borderMid);
      debugPrint('│ 🔸 API RESPONSE');
      debugPrint(borderMid);
      debugPrint('│ STATUS : ${response.statusCode}');
      try {
        final formatted = const JsonEncoder.withIndent('  ').convert(
          json.decode(response.body),
        );
        for (var line in formatted.split('\n')) {
          debugPrint('│ $line');
        }
      } catch (_) {
        final body = response.body;
        if (body.length > 500) {
          debugPrint('│ ${body.substring(0, 500)}...[TRUNCATED]');
        } else {
          debugPrint('│ $body');
        }
      }
    }

    debugPrint(borderBottom);
  }

  /// GET request
  Future<dynamic> get(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    await _loadToken();
    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _printApiLog(
        method: 'GET',
        url: url,
        headers: requestHeaders,
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

  /// POST request
  Future<dynamic> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    await _loadToken();
    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(headers);

    try {
      debugPrint('📤 POST Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(body),
      );

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

  /// PUT request
  Future<dynamic> put(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
      }) async {
    await _loadToken();
    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(headers);

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(body),
      );

      _printApiLog(
        method: 'PUT',
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

  /// DELETE request
  Future<dynamic> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    await _loadToken();
    final url = '$baseUrl$endpoint';
    final requestHeaders = _getHeaders(headers);

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _printApiLog(
        method: 'DELETE',
        url: url,
        headers: requestHeaders,
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

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('Invalid JSON response');
      }
    } else if (response.statusCode == 401) {
      // Unauthorized - token expired or invalid
      clearToken();
      throw ApiException(
        'Unauthorized - Please login again',
        statusCode: response.statusCode,
      );
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