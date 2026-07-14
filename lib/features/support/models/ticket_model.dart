class SupportTicket {
  final int id;
  final String ticketNumber;
  final String uid;
  final String category;
  final String priority;
  final String status;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String subject;
  final String description;
  final String? fleetOwnerName;
  final String? fleetOwnerEmail;
  final String? organizationName;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<TicketMessage> messages;

  SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.uid,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedStaffId,
    this.assignedStaffName,
    required this.subject,
    required this.description,
    this.fleetOwnerName,
    this.fleetOwnerEmail,
    this.organizationName,
    required this.createdAt,
    this.resolvedAt,
    this.messages = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      uid: json['uid'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Open',
      assignedStaffId: json['assigned_staff_id'],
      assignedStaffName: json['assigned_staff_name'],
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      fleetOwnerName: json['fleet_owner_name'],
      fleetOwnerEmail: json['fleet_owner_email'],
      organizationName: json['organization_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      messages: (json['messages'] as List? ?? [])
          .map((m) => TicketMessage.fromJson(m))
          .toList(),
    );
  }
}

class TicketMessage {
  final int id;
  final String ticketNumber;
  final String senderId;
  final String? senderName;
  final String? senderRole;
  final String message;
  final List<String> attachments;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.ticketNumber,
    required this.senderId,
    this.senderName,
    this.senderRole,
    required this.message,
    this.attachments = const [],
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
      message: json['message'] ?? '',
      attachments: (json['attachments'] as List? ?? []).cast<String>(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class SupportAnalytics {
  final Map<String, int> byStatus;
  final Map<String, int> byCategory;
  final Map<String, int> byPriority;
  final int total;

  SupportAnalytics({
    required this.byStatus,
    required this.byCategory,
    required this.byPriority,
    required this.total,
  });

  factory SupportAnalytics.fromJson(Map<String, dynamic> json) {
    return SupportAnalytics(
      byStatus: (json['byStatus'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
      byCategory: (json['byCategory'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
      byPriority: (json['byPriority'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
      total: json['total'] ?? 0,
    );
  }
}
