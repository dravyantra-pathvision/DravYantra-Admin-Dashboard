import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/vehicles_service.dart';

class VehiclesProvider with ChangeNotifier {
  final VehiclesService _service = VehiclesService();

  List<Vehicle> _vehicles = [];
  int _totalVehicles = 0;
  bool _isLoading = false;
  String _error = '';

  int _currentPage = 1;
  final int _limit = 50;

  String? _searchQuery;
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedOrganization;

  Vehicle? _currentVehicleDetail;
  List<VehicleAuditLog> _currentAuditLogs = [];
  bool _isDetailLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  int get totalVehicles => _totalVehicles;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentPage => _currentPage;
  int get limit => _limit;

  Vehicle? get currentVehicleDetail => _currentVehicleDetail;
  List<VehicleAuditLog> get currentAuditLogs => _currentAuditLogs;
  bool get isDetailLoading => _isDetailLoading;

  String? get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;
  String? get selectedType => _selectedType;
  String? get selectedOrganization => _selectedOrganization;

  Future<void> loadVehicles({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _service.getAllVehicles(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
        status: _selectedStatus,
        type: _selectedType,
        organization: _selectedOrganization,
      );
      _vehicles = result['vehicles'];
      _totalVehicles = result['total'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadVehicles(resetPage: true);
  }

  void setFilters({String? status, String? type, String? organization}) {
    _selectedStatus = status;
    _selectedType = type;
    _selectedOrganization = organization;
    loadVehicles(resetPage: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedStatus = null;
    _selectedType = null;
    _selectedOrganization = null;
    loadVehicles(resetPage: true);
  }

  void nextPage() {
    if ((_currentPage * _limit) < _totalVehicles) {
      _currentPage++;
      loadVehicles();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadVehicles();
    }
  }

  Future<void> loadVehicleDetail(String plate) async {
    _isDetailLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentVehicleDetail = await _service.getVehicleDetail(plate);
      _currentAuditLogs = await _service.getVehicleAuditLogs(plate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockVehicle(String plate, String reason, String remarks) async {
    await _service.blockVehicle(plate, reason, remarks);
    await loadVehicleDetail(plate);
    await loadVehicles();
  }

  Future<void> suspendVehicle(String plate, String reason, String remarks) async {
    await _service.suspendVehicle(plate, reason, remarks);
    await loadVehicleDetail(plate);
    await loadVehicles();
  }

  Future<void> reactivateVehicle(String plate) async {
    await _service.reactivateVehicle(plate);
    await loadVehicleDetail(plate);
    await loadVehicles();
  }
}
