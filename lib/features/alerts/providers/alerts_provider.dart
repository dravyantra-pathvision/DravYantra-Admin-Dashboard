import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/alerts_service.dart';

class AlertsProvider with ChangeNotifier {
  final AlertsService _service = AlertsService();

  // ── State ──────────────────────────────────────────────────────────────────
  List<AlertModel> _alerts = [];
  AlertModel? _selectedAlert;
  AlertStatistics? _statistics;
  Map<String, List<String>> _filterOptions = {'types': [], 'organizations': []};

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _error;
  int _totalAlerts = 0;
  int _currentPage = 1;
  final int _limit = 25;

  Timer? _refreshTimer;

  // ── Filters ────────────────────────────────────────────────────────────────
  String _search = '';
  String _orgFilter = 'All';
  String _fleetFilter = 'All';
  String _severityFilter = 'All';
  String _statusFilter = 'All';
  String _typeFilter = 'All';
  String? _fromDate;
  String? _toDate;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<AlertModel> get alerts => _alerts;
  AlertModel? get selectedAlert => _selectedAlert;
  AlertStatistics? get statistics => _statistics;
  Map<String, List<String>> get filterOptions => _filterOptions;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get error => _error;
  int get totalAlerts => _totalAlerts;
  int get currentPage => _currentPage;
  int get limit => _limit;

  String get search => _search;
  String get orgFilter => _orgFilter;
  String get fleetFilter => _fleetFilter;
  String get severityFilter => _severityFilter;
  String get statusFilter => _statusFilter;
  String get typeFilter => _typeFilter;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;

  // ── Initialization ─────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await Future.wait([
      fetchAlerts(refresh: true),
      fetchStatistics(),
      _loadFilterOptions(),
    ]);
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchAlerts(refresh: true, silent: true);
      fetchStatistics();
    });
  }

  void stopRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // ── Fetch alerts list ──────────────────────────────────────────────────────
  Future<void> fetchAlerts({bool refresh = false, bool silent = false}) async {
    if (refresh) {
      _currentPage = 1;
      if (!silent) _alerts = [];
    }

    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final result = await _service.getAllAlerts(
        page: _currentPage,
        limit: _limit,
        search: _search,
        organization: _orgFilter != 'All' ? _orgFilter : null,
        severity: _severityFilter != 'All' ? _severityFilter : null,
        status: _statusFilter != 'All' ? _statusFilter : null,
        type: _typeFilter != 'All' ? _typeFilter : null,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      final newAlerts = result['alerts'] as List<AlertModel>;
      if (refresh) {
        _alerts = newAlerts;
      } else {
        _alerts.addAll(newAlerts);
      }
      _totalAlerts = result['total'] as int;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_alerts.length < _totalAlerts) {
      _currentPage++;
      await fetchAlerts();
    }
  }

  // ── Fetch statistics ───────────────────────────────────────────────────────
  Future<void> fetchStatistics() async {
    try {
      _statistics = await _service.getStatistics();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadFilterOptions() async {
    try {
      _filterOptions = await _service.getFilterOptions();
      notifyListeners();
    } catch (_) {}
  }

  // ── Select / load alert detail ─────────────────────────────────────────────
  Future<void> selectAlert(int id) async {
    _isDetailLoading = true;
    notifyListeners();
    try {
      _selectedAlert = await _service.getAlertById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedAlert() {
    _selectedAlert = null;
    notifyListeners();
  }

  // ── Admin actions ──────────────────────────────────────────────────────────
  Future<bool> updateStatus(int id, String status, {String? notes}) async {
    try {
      final ok = await _service.updateAlertStatus(id, status, notes: notes);
      if (ok) {
        await selectAlert(id);
        fetchAlerts(refresh: true, silent: true);
        fetchStatistics();
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment(int id, String comment) async {
    try {
      final ok = await _service.addComment(id, comment);
      if (ok) await selectAlert(id);
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> notifyFleetOwner(int id) async {
    try {
      final ok = await _service.notifyFleetOwner(id);
      if (ok) await selectAlert(id);
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Filter setters ─────────────────────────────────────────────────────────
  void setSearch(String v) { _search = v; fetchAlerts(refresh: true); }
  void setOrgFilter(String v) { _orgFilter = v; fetchAlerts(refresh: true); }
  void setSeverityFilter(String v) { _severityFilter = v; fetchAlerts(refresh: true); }
  void setStatusFilter(String v) { _statusFilter = v; fetchAlerts(refresh: true); }
  void setTypeFilter(String v) { _typeFilter = v; fetchAlerts(refresh: true); }
  void setDateRange(String? from, String? to) { _fromDate = from; _toDate = to; fetchAlerts(refresh: true); }
  void clearFilters() {
    _search = ''; _orgFilter = 'All'; _fleetFilter = 'All';
    _severityFilter = 'All'; _statusFilter = 'All'; _typeFilter = 'All';
    _fromDate = null; _toDate = null;
    fetchAlerts(refresh: true);
  }

  @override
  void dispose() {
    stopRefresh();
    super.dispose();
  }
}
