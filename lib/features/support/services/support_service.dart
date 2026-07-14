import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/ticket_model.dart';

class SupportService {
  final ApiClient _api = ApiClient.instance;

  Future<List<SupportTicket>> getAllTickets({
    String? status,
    String? priority,
    String? category,
  }) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (priority != null && priority.isNotEmpty) params['priority'] = priority;
    if (category != null && category.isNotEmpty) params['category'] = category;

    final data = await _api.get(ApiEndpoints.supportTickets, queryParams: params);
    final list = data['data'] as List? ?? [];
    return list.map((e) => SupportTicket.fromJson(e)).toList();
  }

  Future<SupportTicket> getTicketDetail(String ticketNumber) async {
    final data = await _api.get(ApiEndpoints.supportTicket(ticketNumber));
    return SupportTicket.fromJson(data['data']);
  }

  Future<SupportTicket> updateTicket(
    String ticketNumber, {
    String? status,
    String? priority,
    String? assignedStaffId,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (priority != null) body['priority'] = priority;
    if (assignedStaffId != null) body['assigned_staff_id'] = assignedStaffId;
    final data = await _api.patch(ApiEndpoints.supportTicket(ticketNumber), body);
    return SupportTicket.fromJson(data['data']);
  }

  Future<TicketMessage> addMessage(
    String ticketNumber,
    String message, {
    List<String> attachments = const [],
  }) async {
    final data = await _api.post(ApiEndpoints.ticketMessages(ticketNumber), {
      'message': message,
      'attachments': attachments,
    });
    return TicketMessage.fromJson(data['data']);
  }

  Future<SupportAnalytics> getAnalytics() async {
    final data = await _api.get(ApiEndpoints.supportAnalytics);
    return SupportAnalytics.fromJson(data['data']);
  }
}
