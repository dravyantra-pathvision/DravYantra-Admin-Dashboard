import 'package:flutter/foundation.dart';
import 'models/system_settings_model.dart';
import 'settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _service = SettingsService();

  Map<String, List<SystemSetting>> _groupedSettings = {};
  List<SettingHistory> _history = [];
  bool _isLoading = false;
  String? _error;

  Map<String, List<SystemSetting>> get groupedSettings => _groupedSettings;
  List<SettingHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groupedSettings = await _service.getAllSettings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory({String? key}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _service.getSettingsHistory(key: key);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<SettingHistory>> getHistoryFor(String key) async {
    return await _service.getSettingsHistory(key: key);
  }


  Future<bool> updateSetting({
    required String key,
    required dynamic value,
    required String category,
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateSetting(
        key: key,
        value: value,
        reason: reason,
      );

      // Update local state
      if (_groupedSettings.containsKey(category)) {
        final index = _groupedSettings[category]!.indexWhere((s) => s.key == key);
        if (index != -1) {
          _groupedSettings[category]![index] = updated;
        }
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
