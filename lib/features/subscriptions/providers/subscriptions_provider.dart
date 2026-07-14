import 'package:flutter/material.dart';
import '../models/subscription_models.dart';
import '../services/subscriptions_service.dart';

class SubscriptionsProvider with ChangeNotifier {
  final SubscriptionsService _service = SubscriptionsService();

  // ── Dashboard State ───────────────────────────────────────────────────────
  SubscriptionDashboardStats? _dashboardStats;
  bool _isDashboardLoading = false;

  // ── Plans State ───────────────────────────────────────────────────────────
  List<SubscriptionPlan> _plans = [];
  bool _isPlansLoading = false;

  // ── Subscriptions State ───────────────────────────────────────────────────
  List<OrganizationSubscription> _subscriptions = [];
  int _totalSubscriptions = 0;
  int _currentPage = 1;
  final int _limit = 50;
  bool _isSubsLoading = false;
  String? _statusFilter;
  String? _searchQuery;

  // ── Invoices State ────────────────────────────────────────────────────────
  List<SubscriptionInvoice> _invoices = [];
  int _totalInvoices = 0;
  int _invoicePage = 1;
  bool _isInvoicesLoading = false;
  String? _invoiceStatusFilter;

  // ── Common ────────────────────────────────────────────────────────────────
  String _error = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  SubscriptionDashboardStats? get dashboardStats => _dashboardStats;
  bool get isDashboardLoading => _isDashboardLoading;

  List<SubscriptionPlan> get plans => _plans;
  bool get isPlansLoading => _isPlansLoading;

  List<OrganizationSubscription> get subscriptions => _subscriptions;
  int get totalSubscriptions => _totalSubscriptions;
  bool get isSubsLoading => _isSubsLoading;
  int get currentPage => _currentPage;
  int get limit => _limit;
  String? get statusFilter => _statusFilter;
  String? get searchQuery => _searchQuery;

  List<SubscriptionInvoice> get invoices => _invoices;
  int get totalInvoices => _totalInvoices;
  bool get isInvoicesLoading => _isInvoicesLoading;
  int get invoicePage => _invoicePage;
  String? get invoiceStatusFilter => _invoiceStatusFilter;

  String get error => _error;

  // ── Dashboard ─────────────────────────────────────────────────────────────
  Future<void> loadDashboard() async {
    _isDashboardLoading = true;
    _error = '';
    notifyListeners();
    try {
      _dashboardStats = await _service.getDashboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  // ── Plans ─────────────────────────────────────────────────────────────────
  Future<void> loadPlans() async {
    _isPlansLoading = true;
    _error = '';
    notifyListeners();
    try {
      _plans = await _service.getAllPlans();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isPlansLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPlan(Map<String, dynamic> body) async {
    await _service.createPlan(body);
    await loadPlans();
    await loadDashboard();
  }

  Future<void> updatePlan(int id, Map<String, dynamic> body) async {
    await _service.updatePlan(id, body);
    await loadPlans();
  }

  Future<void> deletePlan(int id) async {
    await _service.deletePlan(id);
    await loadPlans();
    await loadDashboard();
  }

  // ── Subscriptions ─────────────────────────────────────────────────────────
  Future<void> loadSubscriptions({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    _isSubsLoading = true;
    _error = '';
    notifyListeners();
    try {
      final result = await _service.getAllSubscriptions(
        page: _currentPage,
        limit: _limit,
        status: _statusFilter,
        search: _searchQuery,
      );
      _subscriptions = result['subscriptions'];
      _totalSubscriptions = result['total'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubsLoading = false;
      notifyListeners();
    }
  }

  void setSubsFilter({String? status, String? search}) {
    _statusFilter = status;
    _searchQuery = search;
    loadSubscriptions(resetPage: true);
  }

  void setSubsSearch(String query) {
    _searchQuery = query;
    loadSubscriptions(resetPage: true);
  }

  void clearSubsFilters() {
    _statusFilter = null;
    _searchQuery = null;
    loadSubscriptions(resetPage: true);
  }

  void subsNextPage() {
    if ((_currentPage * _limit) < _totalSubscriptions) {
      _currentPage++;
      loadSubscriptions();
    }
  }

  void subsPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadSubscriptions();
    }
  }

  Future<void> assignPlan({required String orgUid, required int planId, String? notes}) async {
    await _service.assignPlan(orgUid: orgUid, planId: planId, notes: notes);
    await loadSubscriptions();
    await loadDashboard();
  }

  Future<void> activateSubscription(int id) async {
    await _service.activateSubscription(id);
    await loadSubscriptions();
    await loadDashboard();
  }

  Future<void> suspendSubscription(int id, {String? reason}) async {
    await _service.suspendSubscription(id, reason: reason);
    await loadSubscriptions();
    await loadDashboard();
  }

  Future<void> renewSubscription(int id) async {
    await _service.renewSubscription(id);
    await loadSubscriptions();
    await loadDashboard();
  }

  Future<void> extendTrial(int id, {int extraDays = 7}) async {
    await _service.extendTrial(id, extraDays: extraDays);
    await loadSubscriptions();
    await loadDashboard();
  }

  Future<void> cancelSubscription(int id, {String? reason}) async {
    await _service.cancelSubscription(id, reason: reason);
    await loadSubscriptions();
    await loadDashboard();
  }

  // ── Invoices ──────────────────────────────────────────────────────────────
  Future<void> loadInvoices({bool resetPage = false}) async {
    if (resetPage) _invoicePage = 1;
    _isInvoicesLoading = true;
    _error = '';
    notifyListeners();
    try {
      final result = await _service.getAllInvoices(
        page: _invoicePage,
        limit: _limit,
        status: _invoiceStatusFilter,
      );
      _invoices = result['invoices'];
      _totalInvoices = result['total'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isInvoicesLoading = false;
      notifyListeners();
    }
  }

  void setInvoiceFilter(String? status) {
    _invoiceStatusFilter = status;
    loadInvoices(resetPage: true);
  }

  Future<void> generateInvoice({required int subscriptionId, String? orgUid, String? notes}) async {
    await _service.generateInvoice(subscriptionId: subscriptionId, orgUid: orgUid, notes: notes);
    await loadInvoices();
    await loadDashboard();
  }

  Future<void> markInvoicePaid(int id, {String? paymentMethod}) async {
    await _service.markInvoicePaid(id, paymentMethod: paymentMethod);
    await loadInvoices();
    await loadDashboard();
  }
}
