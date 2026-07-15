import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../services/support_service.dart';

class SupportProvider with ChangeNotifier {
  final SupportService _service = SupportService();

  List<SupportTicket> _tickets = [];
  SupportTicket? _selectedTicket;
  SupportAnalytics? _analytics;
  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _error;

  // Filters
  String _statusFilter = '';
  String _priorityFilter = '';
  String _categoryFilter = '';

  List<SupportTicket> get tickets => _tickets;
  SupportTicket? get selectedTicket => _selectedTicket;
  SupportAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get error => _error;
  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get categoryFilter => _categoryFilter;

  void setFilters({String status = '', String priority = '', String category = ''}) {
    _statusFilter = status;
    _priorityFilter = priority;
    _categoryFilter = category;
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tickets = await _service.getAllTickets(
        status: _statusFilter.isEmpty ? null : _statusFilter,
        priority: _priorityFilter.isEmpty ? null : _priorityFilter,
        category: _categoryFilter.isEmpty ? null : _categoryFilter,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalytics() async {
    try {
      _analytics = await _service.getAnalytics();
      notifyListeners();
    } catch (e) {
      // non-critical: fail silently for analytics
    }
  }

  Future<void> fetchTicketDetail(String ticketNumber, {bool showLoading = true}) async {
    if (showLoading) {
      _isDetailLoading = true;
      notifyListeners();
    }
    try {
      final newTicket = await _service.getTicketDetail(ticketNumber);
      
      bool hasChanges = false;
      if (_selectedTicket == null || 
          _selectedTicket!.messages.length != newTicket.messages.length ||
          _selectedTicket!.status != newTicket.status ||
          _selectedTicket!.priority != newTicket.priority) {
        hasChanges = true;
      }
      
      if (hasChanges || showLoading) {
        _selectedTicket = newTicket;
      }
      
      if (showLoading) {
        _isDetailLoading = false;
        notifyListeners();
      } else if (hasChanges) {
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      if (showLoading) {
        _isDetailLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateTicket(
    String ticketNumber, {
    String? status,
    String? priority,
    String? assignedStaffId,
  }) async {
    try {
      final updated = await _service.updateTicket(
        ticketNumber,
        status: status,
        priority: priority,
        assignedStaffId: assignedStaffId,
      );
      _selectedTicket = updated;
      // Also refresh in list
      final idx = _tickets.indexWhere((t) => t.ticketNumber == ticketNumber);
      if (idx != -1) _tickets[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMessage(String ticketNumber, String message) async {
    try {
      final msg = await _service.addMessage(ticketNumber, message);
      if (_selectedTicket != null && _selectedTicket!.ticketNumber == ticketNumber) {
        final updatedMessages = [..._selectedTicket!.messages, msg];
        _selectedTicket = SupportTicket(
          id: _selectedTicket!.id,
          ticketNumber: _selectedTicket!.ticketNumber,
          uid: _selectedTicket!.uid,
          category: _selectedTicket!.category,
          priority: _selectedTicket!.priority,
          status: _selectedTicket!.status,
          assignedStaffId: _selectedTicket!.assignedStaffId,
          assignedStaffName: _selectedTicket!.assignedStaffName,
          subject: _selectedTicket!.subject,
          description: _selectedTicket!.description,
          fleetOwnerName: _selectedTicket!.fleetOwnerName,
          fleetOwnerEmail: _selectedTicket!.fleetOwnerEmail,
          organizationName: _selectedTicket!.organizationName,
          createdAt: _selectedTicket!.createdAt,
          resolvedAt: _selectedTicket!.resolvedAt,
          messages: updatedMessages,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
