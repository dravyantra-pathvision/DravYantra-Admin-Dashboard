class ScheduledReport {
  final String id;
  final String reportType;
  final String format;
  final String scheduleType;
  final List<String> emailRecipients;
  final bool isActive;
  final DateTime nextRunAt;
  final Map<String, dynamic> filters;

  ScheduledReport({
    required this.id,
    required this.reportType,
    required this.format,
    required this.scheduleType,
    required this.emailRecipients,
    required this.isActive,
    required this.nextRunAt,
    required this.filters,
  });

  factory ScheduledReport.fromJson(Map<String, dynamic> json) {
    return ScheduledReport(
      id: json['id'].toString(),
      reportType: json['report_type'] ?? 'Unknown',
      format: json['format'] ?? 'Unknown',
      scheduleType: json['schedule_type'] ?? 'Unknown',
      emailRecipients: List<String>.from(json['email_recipients'] ?? []),
      isActive: json['is_active'] ?? false,
      nextRunAt: DateTime.parse(json['next_run_at']),
      filters: json['filters'] != null ? Map<String, dynamic>.from(json['filters']) : {},
    );
  }
}
