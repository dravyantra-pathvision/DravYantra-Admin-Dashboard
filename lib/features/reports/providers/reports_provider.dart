import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import '../../../core/storage/secure_storage.dart';
import '../../../app/constants.dart';
import '../models/report_history.dart';
import '../models/scheduled_report.dart';

class ReportsProvider with ChangeNotifier {
  static const String _base = '${AppConstants.apiBaseUrl}/api/admin/reports-center';

  List<ReportHistory> _history = [];
  List<ScheduledReport> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<ReportHistory> get history => _history;
  List<ScheduledReport> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchHistory() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('$_base/history'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          _history = decoded.map((d) => ReportHistory.fromJson(d)).toList();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('ReportsProvider.fetchHistory error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSchedules() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('$_base/schedule'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          _schedules = decoded.map((d) => ScheduledReport.fromJson(d)).toList();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('ReportsProvider.fetchSchedules error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> generateReport(
    String reportType,
    String format,
    Map<String, dynamic> filters,
  ) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_base/generate'),
        headers: await _headers(),
        body: jsonEncode({
          'reportType': reportType,
          'format': format,
          'filters': filters,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final newReport = ReportHistory.fromJson(body['report']);
          _history.insert(0, newReport);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('ReportsProvider.generateReport error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> scheduleReport(
    String reportType,
    String format,
    String scheduleType,
    List<String> emailRecipients,
    Map<String, dynamic> filters,
  ) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_base/schedule'),
        headers: await _headers(),
        body: jsonEncode({
          'reportType': reportType,
          'format': format,
          'scheduleType': scheduleType,
          'emailRecipients': emailRecipients,
          'filters': filters,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          await fetchSchedules();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('ReportsProvider.scheduleReport error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHistory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/history/$id'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _history.removeWhere((h) => h.id == id);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/schedule/$id'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _schedules.removeWhere((s) => s.id == id);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void downloadReport(String fileUrl) {
    final fullUrl = '${AppConstants.apiBaseUrl}$fileUrl';
    (html.AnchorElement(href: fullUrl)
      ..setAttribute('download', fileUrl.split('/').last))
      .click();
    debugPrint('Downloading: $fullUrl');
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
