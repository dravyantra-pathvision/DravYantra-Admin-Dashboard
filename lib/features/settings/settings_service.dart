import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import 'models/system_settings_model.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all grouped settings
  Future<Map<String, List<SystemSetting>>> getAllSettings() async {
    try {
      final data = await _apiClient.get(ApiEndpoints.settings);
      if (data['success'] == true) {
        final grouped = data['data'] as Map<String, dynamic>;
        final Map<String, List<SystemSetting>> result = {};
        
        grouped.forEach((category, list) {
          result[category] = (list as List)
              .map((e) => SystemSetting.fromJson(e))
              .toList();
        });
        
        return result;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch settings');
      }
    } catch (e) {
      throw Exception('Error fetching settings: $e');
    }
  }

  /// Update a specific setting
  Future<SystemSetting> updateSetting({
    required String key,
    required dynamic value,
    String? reason,
  }) async {
    try {
      final data = await _apiClient.put(
        ApiEndpoints.setting(key),
        {
          'value': value,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      
      if (data['success'] == true) {
        return SystemSetting.fromJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to update setting');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Get settings history
  Future<List<SettingHistory>> getSettingsHistory({
    String? key,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String url = '${ApiEndpoints.settingsHistory}?page=$page&limit=$limit';
      if (key != null) url += '&key=$key';
      
      final data = await _apiClient.get(url);
      if (data['success'] == true) {
        final historyList = data['history'] as List;
        return historyList.map((e) => SettingHistory.fromJson(e)).toList();
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch settings history');
      }
    } catch (e) {
      throw Exception('Error fetching settings history: $e');
    }
  }
}
