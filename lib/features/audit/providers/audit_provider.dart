import 'package:flutter/foundation.dart';
import '../models/system_audit_log_model.dart';
import '../services/audit_service.dart';

class AuditProvider with ChangeNotifier {
  final AuditService _auditService = AuditService();

  List<SystemAuditLog> _logs = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _limit = 25;

  String? _selectedModule;
  String? _searchQuery;
  String? _startDate;
  String? _endDate;

  List<SystemAuditLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String? get selectedModule => _selectedModule;

  Future<void> fetchLogs({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _auditService.getSystemAuditLogs(
        page: page,
        limit: _limit,
        module: _selectedModule,
        user: _searchQuery,
        startDate: _startDate,
        endDate: _endDate,
      );

      _logs = result['logs'];
      _currentPage = result['pagination']['currentPage'];
      _totalPages = result['pagination']['totalPages'];
      _totalItems = result['pagination']['totalItems'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter({String? module, String? query, String? startDate, String? endDate}) {
    if (module != null) _selectedModule = module;
    if (query != null) _searchQuery = query;
    if (startDate != null) _startDate = startDate;
    if (endDate != null) _endDate = endDate;
    fetchLogs(page: 1);
  }

  void clearFilters() {
    _selectedModule = null;
    _searchQuery = null;
    _startDate = null;
    _endDate = null;
    fetchLogs(page: 1);
  }

  Future<String> exportLogs() async {
    return await _auditService.exportSystemAuditLogs(
      module: _selectedModule,
      user: _searchQuery,
      startDate: _startDate,
      endDate: _endDate,
    );
  }
}
