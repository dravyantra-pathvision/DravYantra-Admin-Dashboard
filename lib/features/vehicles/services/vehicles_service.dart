import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/vehicle_model.dart';

class VehiclesService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getAllVehicles({
    int page = 1,
    int limit = 50,
    String? search,
    String? type,
    String? fuelType,
    String? status,
    String? organization,
    String? fleetOwner,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (fuelType != null && fuelType.isNotEmpty) queryParams['fuelType'] = fuelType;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (organization != null && organization.isNotEmpty) queryParams['organization'] = organization;
    if (fleetOwner != null && fleetOwner.isNotEmpty) queryParams['fleetOwner'] = fleetOwner;

    final decoded = await _api.get('${ApiEndpoints.base}/api/admin/vehicles', queryParams: queryParams);
    final List<dynamic> data = decoded['data'] ?? [];
    final total = decoded['total'] ?? 0;
    return {
      'vehicles': data.map((v) => Vehicle.fromJson(v)).toList(),
      'total': total,
    };
  }

  Future<Vehicle> getVehicleDetail(String plate) async {
    final decoded = await _api.get('${ApiEndpoints.base}/api/admin/vehicles/$plate');
    return Vehicle.fromJson(decoded['data']);
  }

  Future<List<VehicleAuditLog>> getVehicleAuditLogs(String plate) async {
    final decoded = await _api.get('${ApiEndpoints.base}/api/admin/vehicles/$plate/logs');
    final List<dynamic> data = decoded['data'] ?? [];
    return data.map((l) => VehicleAuditLog.fromJson(l)).toList();
  }

  Future<void> blockVehicle(String plate, String reason, String remarks) async {
    await _api.post(
      '${ApiEndpoints.base}/api/admin/vehicles/$plate/block',
      {
        'reason': reason,
        'remarks': remarks,
      },
    );
  }

  Future<void> suspendVehicle(String plate, String reason, String remarks) async {
    await _api.post(
      '${ApiEndpoints.base}/api/admin/vehicles/$plate/suspend',
      {
        'reason': reason,
        'remarks': remarks,
      },
    );
  }

  Future<void> reactivateVehicle(String plate) async {
    await _api.post(
      '${ApiEndpoints.base}/api/admin/vehicles/$plate/reactivate',
      {},
    );
  }
}
