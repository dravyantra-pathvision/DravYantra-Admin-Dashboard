import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/dashboard_models.dart';

class AdminDashboardService {
  Future<Map<String, dynamic>> fetchDashboardSummary() async {
    final response = await ApiClient.instance.get(ApiEndpoints.dashboard);
    
    final data = response['data'] ?? response;

    final statistics = data['statistics'] ?? {};
    final recentOrgs = (data['recentOrganizations'] as List?)
            ?.map((e) => DashboardOrganization.fromJson(e))
            .toList() ??
        [];
    final recentAlerts = (data['recentAlerts'] as List?)
            ?.map((e) => DashboardAlert.fromJson(e))
            .toList() ??
        [];
    final recentOwners = (data['recentFleetOwners'] as List?)
            ?.map((e) => DashboardFleetOwner.fromJson(e))
            .toList() ??
        [];

    return {
      'statistics': {
        'totalOrganizations': statistics['totalOrganizations'] ?? 0,
        'totalFleetOwners': statistics['totalFleetOwners'] ?? 0,
        'totalVehicles': statistics['totalVehicles'] ?? 0,
        'totalDrivers': statistics['totalDrivers'] ?? 0,
        'activeTrips': statistics['activeTrips'] ?? 0,
        'onlineDevices': statistics['onlineDevices'] ?? 0,
        'criticalAlerts': statistics['criticalAlerts'] ?? 0,
        'activeSubscriptions': statistics['activeSubscriptions'] ?? 0,
      },
      'recentOrganizations': recentOrgs,
      'recentAlerts': recentAlerts,
      'recentFleetOwners': recentOwners,
    };
  }
}
