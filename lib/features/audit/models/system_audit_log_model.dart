class SystemAuditLog {
  final String id;
  final DateTime timestamp;
  final String module;
  final String action;
  final String? userName;
  final String? userEmail;
  final String? userRole;
  final String? organizationName;
  final String? ipAddress;
  final String? browser;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;

  SystemAuditLog({
    required this.id,
    required this.timestamp,
    required this.module,
    required this.action,
    this.userName,
    this.userEmail,
    this.userRole,
    this.organizationName,
    this.ipAddress,
    this.browser,
    this.oldValue,
    this.newValue,
  });

  factory SystemAuditLog.fromJson(Map<String, dynamic> json) {
    return SystemAuditLog(
      id: json['id'].toString(),
      timestamp: DateTime.parse(json['timestamp']),
      module: json['module'] ?? 'Unknown',
      action: json['action'] ?? 'Unknown',
      userName: json['user_name'],
      userEmail: json['user_email'],
      userRole: json['user_role'],
      organizationName: json['organization_name'],
      ipAddress: json['ip_address'],
      browser: json['browser'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
    );
  }
}
