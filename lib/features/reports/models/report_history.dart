class ReportHistory {
  final String id;
  final String reportType;
  final String format;
  final String fileUrl;
  final String status;
  final DateTime generatedAt;
  final Map<String, dynamic> filters;

  ReportHistory({
    required this.id,
    required this.reportType,
    required this.format,
    required this.fileUrl,
    required this.status,
    required this.generatedAt,
    required this.filters,
  });

  factory ReportHistory.fromJson(Map<String, dynamic> json) {
    return ReportHistory(
      id: json['id'].toString(),
      reportType: json['report_type'] ?? 'Unknown',
      format: json['format'] ?? 'Unknown',
      fileUrl: json['file_url'] ?? '',
      status: json['status'] ?? 'Unknown',
      generatedAt: DateTime.parse(json['generated_at']),
      filters: json['filters'] != null ? Map<String, dynamic>.from(json['filters']) : {},
    );
  }
}
