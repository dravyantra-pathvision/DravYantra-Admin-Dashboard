import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/trip_model.dart';

class TripsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getTrips({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;
    if (fromDate != null && fromDate.isNotEmpty) queryParams['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) queryParams['to_date'] = toDate;

    final response = await _apiClient.get('${ApiEndpoints.base}/api/admin/trips', queryParams: queryParams);
    
    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return {
        'trips': data.map((json) => Trip.fromJson(json)).toList(),
        'total': response['total'] ?? 0,
      };
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch trips');
    }
  }

  Future<Trip> getTripById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.base}/api/admin/trips/$id');
    if (response['success'] == true && response['trip'] != null) {
      return Trip.fromJson(response['trip']);
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch trip details');
    }
  }

  Future<List<dynamic>> getTripTimeline(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.base}/api/admin/trips/$id/timeline');
    if (response['success'] == true) {
      return response['timeline'] as List<dynamic>;
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch trip timeline');
    }
  }

  Future<Uint8List> exportTrips({
    String? search,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;
    if (fromDate != null && fromDate.isNotEmpty) queryParams['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) queryParams['to_date'] = toDate;

    return await _apiClient.downloadFile('${ApiEndpoints.base}/api/admin/trips/export', queryParams: queryParams);
  }
}
