class SystemSetting {
  final String key;
  final dynamic value;
  final String category;
  final bool isSensitive;
  final bool requiresSuperAdmin;
  final String description;
  final String? updatedBy;
  final DateTime? updatedAt;

  SystemSetting({
    required this.key,
    required this.value,
    required this.category,
    required this.isSensitive,
    required this.requiresSuperAdmin,
    required this.description,
    this.updatedBy,
    this.updatedAt,
  });

  factory SystemSetting.fromJson(Map<String, dynamic> json) {
    return SystemSetting(
      key: json['key'] ?? '',
      value: json['value'],
      category: json['category'] ?? '',
      isSensitive: json['isSensitive'] ?? false,
      requiresSuperAdmin: json['requiresSuperAdmin'] ?? false,
      description: json['description'] ?? '',
      updatedBy: json['updatedBy'],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class SettingHistory {
  final int id;
  final String key;
  final dynamic oldValue;
  final dynamic newValue;
  final String? changedBy;
  final String? changedByEmail;
  final DateTime? changedAt;
  final String? changeReason;

  SettingHistory({
    required this.id,
    required this.key,
    this.oldValue,
    this.newValue,
    this.changedBy,
    this.changedByEmail,
    this.changedAt,
    this.changeReason,
  });

  factory SettingHistory.fromJson(Map<String, dynamic> json) {
    return SettingHistory(
      id: json['id'] ?? 0,
      key: json['setting_key'] ?? '',
      oldValue: json['old_value'],
      newValue: json['new_value'],
      changedBy: json['changed_by'],
      changedByEmail: json['changed_by_email'],
      changedAt: json['changed_at'] != null ? DateTime.parse(json['changed_at']) : null,
      changeReason: json['change_reason'],
    );
  }
}
