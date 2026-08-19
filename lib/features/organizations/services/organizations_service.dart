import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';

class OrganizationsService {
  OrganizationsService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getOrganizations({String? status, String? search}) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (status != null && status != 'All') queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    final uri = Uri.parse(ApiEndpoints.organizations).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? []; // Extract the inner data array
    } else {
      throw Exception('Failed to load organizations');
    }
  }

  Future<Map<String, dynamic>> getOrganizationDetail(String uid) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiEndpoints.organization(uid)),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? {};
    } else {
      throw Exception('Failed to load organization detail');
    }
  }

  Future<void> deleteOrganization(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse(ApiEndpoints.organization(id)),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to move organization to Recycle Bin');
    }
  }

  Future<void> deleteOrganizationPermanent(String id) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse(ApiEndpoints.organizationPermanent(id)),
      headers: headers,
    );

    if (response.statusCode != 200) {
      String msg = 'Failed to permanently delete organization';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) msg = body['message'];
        else if (body['error'] != null) msg = body['error'];
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<void> updateStatus(String id, String action, {String? reason}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiEndpoints.organization(id)}/$action'),
      headers: headers,
      body: reason != null ? jsonEncode({'reason': reason}) : jsonEncode({}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to $action organization');
    }
  }
}
