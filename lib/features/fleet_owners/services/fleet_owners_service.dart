import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/constants.dart';
import '../../../core/storage/secure_storage.dart';

class FleetOwnersService {
  FleetOwnersService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getFleetOwners({String? search, String? status, String? orgStatus, int page = 1, int limit = 50}) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;
    if (orgStatus != null && orgStatus.isNotEmpty && orgStatus != 'All') queryParams['orgStatus'] = orgStatus;
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();
    
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/admin/fleetowners').replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    } else {
      throw Exception('Failed to load fleet owners');
    }
  }

  Future<Map<String, dynamic>> getFleetOwnerDetail(String uid) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/fleetowners/$uid'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? {};
    } else {
      throw Exception('Failed to load fleet owner detail');
    }
  }

  Future<void> updateFleetOwner(String uid, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/fleetowners/$uid'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update fleet owner');
    }
  }

  Future<void> updateStatus(String uid, String status) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/fleetowners/$uid/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> deleteFleetOwner(String uid) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/fleetowners/$uid'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete fleet owner');
    }
  }

  Future<String?> resetPassword(String uid) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/fleetowners/$uid/reset-password'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['link'];
    } else {
      throw Exception('Failed to reset password');
    }
  }
}
