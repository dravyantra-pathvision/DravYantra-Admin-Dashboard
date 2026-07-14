import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class LiveService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getLiveDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.liveDashboard);
    return response['data'];
  }

  Future<List<dynamic>> getLiveVehicles({
    String? organization,
    String? fleetOwner,
    String? fleetUid,
    String? status,
    String? alertFilter,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (organization != null && organization.isNotEmpty) queryParams['organization'] = organization;
    if (fleetUid != null && fleetUid.isNotEmpty) queryParams['fleetUid'] = fleetUid;
    if (fleetOwner != null && fleetOwner.isNotEmpty && (fleetUid == null || fleetUid.isEmpty)) queryParams['fleetOwner'] = fleetOwner;
    if (status != null && status != 'All') queryParams['status'] = status;
    if (alertFilter != null && alertFilter != 'All') queryParams['alertFilter'] = alertFilter;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get(ApiEndpoints.liveVehicles, queryParams: queryParams);
    return response['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getLiveVehicleDetail(String id) async {
    final response = await _apiClient.get(ApiEndpoints.liveVehicle(id));
    return response['data'];
  }

  Future<List<dynamic>> getLiveAlerts() async {
    final response = await _apiClient.get(ApiEndpoints.liveAlerts);
    return response['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getLiveStatistics() async {
    final response = await _apiClient.get(ApiEndpoints.liveStatistics);
    return response['data'];
  }

  Future<List<dynamic>> getFleetList() async {
    final response = await _apiClient.get(ApiEndpoints.liveFleetList);
    return response['data'] as List<dynamic>;
  }
}
