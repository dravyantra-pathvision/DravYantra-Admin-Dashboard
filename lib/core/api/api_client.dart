// core/api/api_client.dart
// Centralised HTTP client for all admin API calls.
// Automatically injects Authorization header from stored token.

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // ── Headers ──────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
    if (kDebugMode && token != null && token.length > 10) {
      final maskedToken = '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
      debugPrint('ApiClient Token: $maskedToken');
    } else if (kDebugMode && token != null) {
      debugPrint('ApiClient Token received successfully (too short to mask)');
    }
    return {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Response Handler ─────────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['error'] ?? body['message'] ?? 'Unknown error';
    throw ApiException(response.statusCode, message.toString());
  }

  // ── HTTP Methods ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    if (kDebugMode) {
      debugPrint('ApiClient GET: $uri');
    }
    final response = await http.get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String url) async {
    final response = await http.delete(Uri.parse(url), headers: await _headers())
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String url, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Uint8List> downloadFile(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 30));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException(response.statusCode, 'Failed to download file');
  }
}
