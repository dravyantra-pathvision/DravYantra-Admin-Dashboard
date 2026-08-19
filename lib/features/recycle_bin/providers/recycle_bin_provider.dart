import 'package:flutter/material.dart';
import '../models/recycled_item.dart';
import '../services/recycle_bin_service.dart';

class RecycleBinProvider with ChangeNotifier {
  final RecycleBinService _service = RecycleBinService();

  List<RecycledItem> _items = [];
  int _totalItems = 0;
  bool _isLoading = false;
  String _error = '';

  int _currentPage = 1;
  final int _limit = 50;

  String _selectedType = 'all';
  String _searchQuery = '';

  List<RecycledItem> get items => _items;
  int get totalItems => _totalItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentPage => _currentPage;
  int get limit => _limit;
  String get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  Future<void> fetchItems({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final res = await _service.getRecycledItems(
        type: _selectedType,
        search: _searchQuery,
        page: _currentPage,
        limit: _limit,
      );
      _items = res['items'];
      _totalItems = res['total'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTypeFilter(String type) {
    if (_selectedType != type) {
      _selectedType = type;
      fetchItems(resetPage: true);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchItems(resetPage: true);
  }

  Future<void> restoreItem(String entityType, String id) async {
    await _service.restoreItem(entityType, id);
    await fetchItems(resetPage: true);
  }

  Future<void> hardDeleteItem(String entityType, String id) async {
    await _service.hardDeleteItem(entityType, id);
    await fetchItems(resetPage: true);
  }
}
