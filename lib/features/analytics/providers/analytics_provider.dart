import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  // Filters
  String? _selectedOrgId;
  String? _selectedVehiclePlate;
  String? _selectedDriverId;
  String _selectedPeriod = 'Monthly'; // 'Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom'
  DateTimeRange? _customDateRange;

  // Data Maps
  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? _fuelData;
  Map<String, dynamic>? _vehicleData;
  Map<String, dynamic>? _driverData;
  Map<String, dynamic>? _tripData;
  Map<String, dynamic>? _deviceData;
  Map<String, dynamic>? _environmentData;
  Map<String, dynamic>? _alertData;

  // Status flags
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get selectedOrgId => _selectedOrgId;
  String? get selectedVehiclePlate => _selectedVehiclePlate;
  String? get selectedDriverId => _selectedDriverId;
  String get selectedPeriod => _selectedPeriod;
  DateTimeRange? get customDateRange => _customDateRange;

  Map<String, dynamic>? get overviewData => _overviewData;
  Map<String, dynamic>? get fuelData => _fuelData;
  Map<String, dynamic>? get vehicleData => _vehicleData;
  Map<String, dynamic>? get driverData => _driverData;
  Map<String, dynamic>? get tripData => _tripData;
  Map<String, dynamic>? get deviceData => _deviceData;
  Map<String, dynamic>? get environmentData => _environmentData;
  Map<String, dynamic>? get alertData => _alertData;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper to compile dynamic query parameters based on active filters
  Map<String, String> get queryParams {
    final Map<String, String> params = {};

    if (_selectedOrgId != null && _selectedOrgId!.isNotEmpty) {
      params['organization_id'] = _selectedOrgId!;
    }
    if (_selectedVehiclePlate != null && _selectedVehiclePlate!.isNotEmpty) {
      params['vehicle_plate'] = _selectedVehiclePlate!;
    }
    if (_selectedDriverId != null && _selectedDriverId!.isNotEmpty) {
      params['driver_id'] = _selectedDriverId!;
    }

    // Determine date range based on period
    final now = DateTime.now();
    DateTime? from;
    DateTime? to;

    switch (_selectedPeriod) {
      case 'Daily':
        from = DateTime(now.year, now.month, now.day);
        to = now;
        break;
      case 'Weekly':
        from = now.subtract(const Duration(days: 7));
        to = now;
        break;
      case 'Monthly':
        from = DateTime(now.year, now.month - 1, now.day);
        to = now;
        break;
      case 'Yearly':
        from = DateTime(now.year - 1, now.month, now.day);
        to = now;
        break;
      case 'Custom':
        if (_customDateRange != null) {
          from = _customDateRange!.start;
          to = _customDateRange!.end;
        }
        break;
    }

    if (from != null) {
      params['from_date'] = DateFormat('yyyy-MM-dd').format(from);
    }
    if (to != null) {
      params['to_date'] = DateFormat('yyyy-MM-dd').format(to);
    }

    return params;
  }

  // Fetch all analytics categories — each is independent so one failure doesn't block others
  Future<void> fetchAllAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final filters = queryParams;
    String? firstError;

    Future<T?> safeFetch<T>(Future<T> Function() fn) async {
      try {
        return await fn();
      } catch (e) {
        firstError ??= e.toString().replaceFirst('Exception: ', '');
        return null;
      }
    }

    final results = await Future.wait([
      safeFetch(() => _service.getOverview(filters)),
      safeFetch(() => _service.getFuelAnalytics(filters)),
      safeFetch(() => _service.getVehicleAnalytics(filters)),
      safeFetch(() => _service.getDriverAnalytics(filters)),
      safeFetch(() => _service.getTripAnalytics(filters)),
      safeFetch(() => _service.getDeviceAnalytics(filters)),
    ]);

    _overviewData = results[0] != null ? Map<String, dynamic>.from(results[0] as Map) : null;
    _fuelData = results[1] != null ? Map<String, dynamic>.from(results[1] as Map) : null;
    _vehicleData = results[2] != null ? Map<String, dynamic>.from(results[2] as Map) : null;
    _driverData = results[3] != null ? Map<String, dynamic>.from(results[3] as Map) : null;
    _tripData = results[4] != null ? Map<String, dynamic>.from(results[4] as Map) : null;
    _deviceData = results[5] != null ? Map<String, dynamic>.from(results[5] as Map) : null;

    // Only show error if ALL fetches failed
    final allFailed = results.every((r) => r == null);
    _error = allFailed ? firstError : null;

    _isLoading = false;
    notifyListeners();
  }

  // Setters
  void setOrganization(String? orgId) {
    if (_selectedOrgId != orgId) {
      _selectedOrgId = orgId;
      fetchAllAnalytics();
    }
  }

  void setVehicle(String? plate) {
    if (_selectedVehiclePlate != plate) {
      _selectedVehiclePlate = plate;
      fetchAllAnalytics();
    }
  }

  void setDriver(String? driverId) {
    if (_selectedDriverId != driverId) {
      _selectedDriverId = driverId;
      fetchAllAnalytics();
    }
  }

  void setPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      if (period != 'Custom') {
        fetchAllAnalytics();
      }
    }
  }

  void setCustomDateRange(DateTimeRange range) {
    _customDateRange = range;
    _selectedPeriod = 'Custom';
    fetchAllAnalytics();
  }

  void resetFilters() {
    _selectedOrgId = null;
    _selectedVehiclePlate = null;
    _selectedDriverId = null;
    _selectedPeriod = 'Monthly';
    _customDateRange = null;
    fetchAllAnalytics();
  }

  Future<Uint8List> exportAnalytics(String format) async {
    return await _service.exportAnalytics(queryParams, format);
  }
}
