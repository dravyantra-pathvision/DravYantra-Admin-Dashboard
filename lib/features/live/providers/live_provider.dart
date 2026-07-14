import 'dart:async';
import 'package:flutter/material.dart';
import '../services/live_service.dart';

class LiveProvider with ChangeNotifier {
  final LiveService _service = LiveService();

  Map<String, dynamic>? _dashboardStats;
  List<dynamic> _vehicles = [];
  List<dynamic> _alerts = [];
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _selectedVehicle;
  List<Map<String, dynamic>> _fleetList = []; // Approved fleets with vehicles

  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  // Filters
  String _organizationFilter = '';
  String _fleetOwnerFilter = '';
  String _selectedFleetUid = ''; // New: filter by fleet owner UID
  String _statusFilter = 'All'; // 'All', 'Moving', 'Idle', 'Parked', 'Offline'
  String _alertFilter = 'All'; // 'All', 'critical', 'fuel_theft', 'overspeed'
  String _searchQuery = '';

  // Getters
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<dynamic> get vehicles => _vehicles;
  List<dynamic> get alerts => _alerts;
  Map<String, dynamic>? get statistics => _statistics;
  Map<String, dynamic>? get selectedVehicle => _selectedVehicle;
  List<Map<String, dynamic>> get fleetList => _fleetList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get organizationFilter => _organizationFilter;
  String get fleetOwnerFilter => _fleetOwnerFilter;
  String get selectedFleetUid => _selectedFleetUid;
  String get statusFilter => _statusFilter;
  String get alertFilter => _alertFilter;
  String get searchQuery => _searchQuery;

  void startPolling() {
    _loadFleetList(); // Load fleet list once on start
    _fetchLiveData();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchLiveData(isBackground: true);
    });
  }

  Future<void> _loadFleetList() async {
    try {
      final raw = await _service.getFleetList();
      _fleetList = raw.map((e) => e as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (_) {}
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchLiveData({bool isBackground = false}) async {
    if (!isBackground) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final futures = await Future.wait<dynamic>([
        _service.getLiveDashboard(),
        _service.getLiveVehicles(
          organization: _organizationFilter,
          fleetUid: _selectedFleetUid,
          fleetOwner: _selectedFleetUid.isEmpty ? _fleetOwnerFilter : null,
          status: _statusFilter,
          alertFilter: _alertFilter,
          search: _searchQuery,
        ),
        _service.getLiveAlerts(),
        _service.getLiveStatistics(),
      ]);

      _dashboardStats = futures[0] as Map<String, dynamic>;
      _vehicles = futures[1] as List<dynamic>;
      _alerts = futures[2] as List<dynamic>;
      _statistics = futures[3] as Map<String, dynamic>;

      if (_selectedVehicle != null) {
        _selectedVehicle = await _service.getLiveVehicleDetail(_selectedVehicle!['plate']);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!isBackground) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void setFilters({
    String? organization,
    String? fleetOwner,
    String? fleetUid,
    String? status,
    String? alertFilter,
    String? search,
  }) {
    if (organization != null) _organizationFilter = organization;
    if (fleetOwner != null) _fleetOwnerFilter = fleetOwner;
    if (fleetUid != null) _selectedFleetUid = fleetUid;
    if (status != null) _statusFilter = status;
    if (alertFilter != null) _alertFilter = alertFilter;
    if (search != null) _searchQuery = search;
    
    // Trigger immediate refresh with new filters
    _fetchLiveData();
  }

  Future<void> selectVehicle(String? plate) async {
    if (plate == null) {
      _selectedVehicle = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _selectedVehicle = await _service.getLiveVehicleDetail(plate);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
