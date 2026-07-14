import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/drivers_service.dart';

class DriversProvider with ChangeNotifier {
  List<DriverModel> _drivers = [];
  int _totalDrivers = 0;
  bool _isLoading = false;
  String _error = '';

  int _currentPage = 1;
  final int _limit = 50;
  int _totalPages = 1;

  String? _searchQuery;
  String? _selectedStatus;
  String? _selectedOrganization;

  DriverModel? _currentDriverDetail;
  bool _isDetailLoading = false;

  List<DriverModel> get drivers => _drivers;
  int get totalDrivers => _totalDrivers;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  String? get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;
  String? get selectedOrganization => _selectedOrganization;

  DriverModel? get currentDriverDetail => _currentDriverDetail;
  bool get isDetailLoading => _isDetailLoading;

  Future<void> fetchDrivers({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await DriversService.fetchDrivers(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
        organization: _selectedOrganization,
        status: _selectedStatus,
      );

      final List<dynamic> driversJson = data['drivers'] ?? [];
      _drivers = driversJson.map((json) => DriverModel.fromJson(json)).toList();
      _totalDrivers = data['total'] ?? 0;
      _totalPages = data['totalPages'] ?? 1;
    } catch (e) {
      _error = e.toString();
      _drivers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDriverDetail(String id) async {
    _isDetailLoading = true;
    _error = '';
    notifyListeners();

    try {
      final json = await DriversService.fetchDriverById(id);
      _currentDriverDetail = DriverModel.fromJson(json);
    } catch (e) {
      _error = e.toString();
      _currentDriverDetail = null;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.isEmpty ? null : query;
    fetchDrivers(resetPage: true);
  }

  void setFilter({String? status, String? organization}) {
    if (status != null) _selectedStatus = status == 'All' ? null : status;
    if (organization != null) _selectedOrganization = organization == 'All' ? null : organization;
    fetchDrivers(resetPage: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedStatus = null;
    _selectedOrganization = null;
    fetchDrivers(resetPage: true);
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      fetchDrivers();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      fetchDrivers();
    }
  }

  Future<void> updateDriverStatus(String id, String status, String remarks) async {
    try {
      await DriversService.updateDriverStatus(id, status, remarks);
      // Refresh list and details
      if (_currentDriverDetail?.id == id) {
        await fetchDriverDetail(id);
      }
      await fetchDrivers();
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }
}
