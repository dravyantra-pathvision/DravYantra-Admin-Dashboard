import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/trips_service.dart';

class TripsProvider with ChangeNotifier {
  final TripsService _service = TripsService();

  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;
  int _totalTrips = 0;
  
  // Pagination
  int _currentPage = 1;
  final int _limit = 20;

  // Filters
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Scheduled', 'Running', 'Completed', 'Cancelled', 'Interrupted'
  String? _fromDate;
  String? _toDate;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalTrips => _totalTrips;
  int get currentPage => _currentPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> fetchTrips({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _trips = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getTrips(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
        status: _statusFilter,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (refresh) {
        _trips = List<Trip>.from(result['trips']);
      } else {
        _trips.addAll(List<Trip>.from(result['trips']));
      }
      
      _totalTrips = result['total'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      fetchTrips(refresh: true);
    }
  }

  void setStatusFilter(String status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      fetchTrips(refresh: true);
    }
  }

  void setDateRange(String? from, String? to) {
    if (_fromDate != from || _toDate != to) {
      _fromDate = from;
      _toDate = to;
      fetchTrips(refresh: true);
    }
  }

  void loadNextPage() {
    if (_trips.length < _totalTrips && !_isLoading) {
      _currentPage++;
      fetchTrips();
    }
  }

  Future<Trip> getTripById(String id) async {
    return await _service.getTripById(id);
  }

  Future<List<dynamic>> getTripTimeline(String id) async {
    return await _service.getTripTimeline(id);
  }

  Future<Uint8List> exportTrips() async {
    return await _service.exportTrips(
      search: _searchQuery,
      status: _statusFilter,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }
}
