import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/system_audit_log_model.dart';

class AuditService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getSystemAuditLogs({
    int page = 1,
    int limit = 25,
    String? module,
    String? user,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (module != null && module.isNotEmpty && module != 'All') queryParams['module'] = module;
    if (user != null && user.isNotEmpty) queryParams['user'] = user;
    if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;

    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/admin/audit-logs').replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      final logs = data.map((e) => SystemAuditLog.fromJson(e)).toList();
      return {
        'logs': logs,
        'pagination': jsonResponse['pagination'],
      };
    } else {
      throw Exception('Failed to load audit logs');
    }
  }

  Future<String> exportSystemAuditLogs({
    String? module,
    String? user,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (module != null && module.isNotEmpty && module != 'All') queryParams['module'] = module;
    if (user != null && user.isNotEmpty) queryParams['user'] = user;
    if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;

    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/admin/audit-logs/export').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return response.body; // Returns CSV as String
    } else {
      throw Exception('Failed to export audit logs');
    }
  }
}
