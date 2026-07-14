import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getOverview(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/overview',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch overview analytics');
  }

  Future<Map<String, dynamic>> getFuelAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/fuel',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch fuel analytics');
  }

  Future<Map<String, dynamic>> getVehicleAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/vehicles',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch vehicle analytics');
  }

  Future<Map<String, dynamic>> getDriverAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/drivers',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch driver analytics');
  }

  Future<Map<String, dynamic>> getTripAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/trips',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch trip analytics');
  }

  Future<Map<String, dynamic>> getDeviceAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/devices',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch device analytics');
  }

  Future<Map<String, dynamic>> getEnvironmentAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/environment',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch environment analytics');
  }

  Future<Map<String, dynamic>> getAlertAnalytics(Map<String, String> filters) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.base}/api/admin/analytics/alerts',
      queryParams: filters,
    );
    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to fetch alert analytics');
  }

  Future<Uint8List> exportAnalytics(Map<String, String> filters, String format) async {
    final queryParams = Map<String, String>.from(filters);
    queryParams['format'] = format;

    return await _apiClient.downloadFile(
      '${ApiEndpoints.base}/api/admin/analytics/export',
      queryParams: queryParams,
    );
  }
}
