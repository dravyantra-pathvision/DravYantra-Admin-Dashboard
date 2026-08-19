import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'dart:convert';

class DriversService {
  static final _api = ApiClient.instance;

  // Returns { drivers: List, total: int, page: int, totalPages: int }
  static Future<Map<String, dynamic>> fetchDrivers({
    int page = 1,
    int limit = 10,
    String? search,
    String? organization,
    String? fleetOwner,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (organization != null && organization.isNotEmpty) queryParams['organization'] = organization;
    if (fleetOwner != null && fleetOwner.isNotEmpty) queryParams['fleetOwner'] = fleetOwner;
    if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;

    final decoded = await _api.get(ApiEndpoints.drivers, queryParams: queryParams);
    return decoded; // our backend returns drivers, total, page, totalPages
  }

  static Future<Map<String, dynamic>> fetchDriverById(String id) async {
    final decoded = await _api.get(ApiEndpoints.driver(id));
    return decoded;
  }

  static Future<void> updateDriverStatus(String id, String status, String remarks) async {
    await _api.put(
      ApiEndpoints.driverStatus(id),
      {
        'status': status,
        'remarks': remarks,
      },
    );
  }

  static Future<List<dynamic>> exportDrivers({String? organization, String? status}) async {
    final queryParams = <String, String>{};
    if (organization != null && organization.isNotEmpty) queryParams['organization'] = organization;
    if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;

    final decoded = await _api.get('${ApiEndpoints.drivers}/export', queryParams: queryParams);
    return decoded as List<dynamic>;
  }

  static Future<void> deleteDriver(String id) async {
    await _api.delete(ApiEndpoints.driver(id));
  }

  static Future<void> deleteDriverPermanent(String id) async {
    await _api.delete(ApiEndpoints.driverPermanent(id));
  }
}
