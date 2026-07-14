import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/alert_model.dart';

class AlertsService {
  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> getAllAlerts({
    int page = 1,
    int limit = 20,
    String? search,
    String? organization,
    String? fleetOwner,
    String? severity,
    String? status,
    String? type,
    String? vehicle,
    String? driver,
    String? fromDate,
    String? toDate,
    String sort = 'detected_at',
  }) async {
    final q = <String, String>{'page': '$page', 'limit': '$limit', 'sort': sort};
    if (search?.isNotEmpty == true) q['search'] = search!;
    if (organization?.isNotEmpty == true) q['organization'] = organization!;
    if (fleetOwner?.isNotEmpty == true) q['fleetOwner'] = fleetOwner!;
    if (severity != null && severity != 'All') q['severity'] = severity;
    if (status != null && status != 'All') q['status'] = status;
    if (type != null && type != 'All') q['type'] = type;
    if (vehicle?.isNotEmpty == true) q['vehicle'] = vehicle!;
    if (driver?.isNotEmpty == true) q['driver'] = driver!;
    if (fromDate?.isNotEmpty == true) q['fromDate'] = fromDate!;
    if (toDate?.isNotEmpty == true) q['toDate'] = toDate!;

    final res = await _api.get(ApiEndpoints.alerts, queryParams: q);
    return {
      'alerts': (res['alerts'] as List<dynamic>).map((e) => AlertModel.fromJson(e)).toList(),
      'total': res['total'] ?? 0,
    };
  }

  Future<AlertModel> getAlertById(int id) async {
    final res = await _api.get(ApiEndpoints.alertById(id));
    return AlertModel.fromJson(res['data']);
  }

  Future<bool> updateAlertStatus(int id, String status, {String? notes}) async {
    final body = <String, dynamic>{'status': status};
    if (notes != null) body['notes'] = notes;
    // Use patch via post workaround using the api client
    final res = await _api.patch(ApiEndpoints.alertStatus(id), body);
    return res['success'] == true;
  }

  Future<bool> addComment(int id, String comment) async {
    final res = await _api.post(ApiEndpoints.alertComment(id), {'comment': comment});
    return res['success'] == true;
  }

  Future<bool> notifyFleetOwner(int id) async {
    final res = await _api.post(ApiEndpoints.alertNotify(id), {});
    return res['success'] == true;
  }

  Future<AlertStatistics> getStatistics() async {
    final res = await _api.get(ApiEndpoints.alertStatistics);
    return AlertStatistics.fromJson(res['data']);
  }

  Future<Map<String, List<String>>> getFilterOptions() async {
    final res = await _api.get(ApiEndpoints.alertFilterOptions);
    final data = res['data'];
    return {
      'types': List<String>.from(data['types'] ?? []),
      'organizations': List<String>.from(data['organizations'] ?? []),
    };
  }
}
