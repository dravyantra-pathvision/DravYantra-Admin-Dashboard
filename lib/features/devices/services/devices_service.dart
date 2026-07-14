import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/constants.dart';
import '../../../core/storage/secure_storage.dart';

class DevicesService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getDevices({String? search, String? status, String? manufacturer, String? firmware}) async {
    final headers = await _getHeaders();
    
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'All') queryParams['status'] = status;
    if (manufacturer != null && manufacturer.isNotEmpty) queryParams['manufacturer'] = manufacturer;
    if (firmware != null && firmware.isNotEmpty) queryParams['firmware'] = firmware;
    
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/admin/devices').replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    } else {
      throw Exception('Failed to load devices: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getDeviceDetail(String deviceId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/devices/$deviceId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? {};
    } else {
      throw Exception('Failed to load device detail');
    }
  }

  Future<void> registerDevice(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/devices'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to register device: $error');
    }
  }

  Future<void> updateDeviceStatus(String deviceId, String status) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/devices/$deviceId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update device status');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/api/admin/devices/$deviceId'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete device');
    }
  }
}
