import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/admin_profile_model.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/storage/secure_storage.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<AdminProfile> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return AdminProfile.fromJson(response);
  }

  Future<AdminProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiEndpoints.profile, data);
    return AdminProfile.fromJson(response['profile']);
  }

  Future<void> updateNotificationPreferences(Map<String, dynamic> data) async {
    await _apiClient.put(ApiEndpoints.profileNotifications, data);
  }

  Future<void> changePassword(String newPassword, String confirmPassword) async {
    try {
      await _apiClient.put(
        ApiEndpoints.profilePassword,
        {
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } catch (e) {
      if (e is ApiException) {
        throw Exception(e.message);
      }
      rethrow;
    }
  }

  Future<List<AdminSession>> getSessions() async {
    // get() returns a Map<String, dynamic> normally, but what if the backend returns a list?
    // Looking at api_client, _handleResponse expects a Map. Let me check profile.controller.js.
    // getSessions returns res.status(200).json(sessions); where sessions is an array!
    // Ah, _handleResponse in api_client.dart expects a map. If it returns a list, it will crash `jsonDecode` parsing as Map.
    // Let me check if other lists are returned wrapped in objects.
    // If not, I can bypass ApiClient for this specific call or wrap it.
    // Actually, I'll bypass ApiClient for list fetches and photo upload.
    
    final token = await SecureStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.get(Uri.parse(ApiEndpoints.profileSessions), headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AdminSession.fromJson(json)).toList();
    }
    throw Exception('Failed to load sessions');
  }

  Future<void> terminateSession(String sessionId) async {
    await _apiClient.delete(ApiEndpoints.profileSession(sessionId));
  }

  Future<String> uploadPhoto(List<int> bytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.profilePhoto));
    
    // Add token header
    final token = await SecureStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'photo',
      bytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'), 
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['photoUrl'];
    }
    
    throw Exception('Failed to upload photo');
  }

  Future<void> removePhoto() async {
    await _apiClient.delete(ApiEndpoints.profilePhoto);
  }
}
