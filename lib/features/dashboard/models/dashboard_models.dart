class DashboardOrganization {
  final String id;
  final String name;
  final String adminEmail;
  final int vehicleCount;
  final String status;

  DashboardOrganization({
    required this.id,
    required this.name,
    required this.adminEmail,
    required this.vehicleCount,
    required this.status,
  });

  factory DashboardOrganization.fromJson(Map<String, dynamic> json) {
    return DashboardOrganization(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      adminEmail: json['adminEmail'] ?? '',
      vehicleCount: int.tryParse(json['vehicleCount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'Active',
    );
  }
}

class DashboardFleetOwner {
  final String id;
  final String name;
  final String email;
  final String organization;
  final String joinedDate;
  final String status;

  DashboardFleetOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.organization,
    required this.joinedDate,
    required this.status,
  });

  factory DashboardFleetOwner.fromJson(Map<String, dynamic> json) {
    return DashboardFleetOwner(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? 'N/A',
      organization: json['organization'] ?? 'N/A',
      joinedDate: json['joinedDate'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }
}

class DashboardAlert {
  final String id;
  final String message;
  final String vehicleId;
  final String severity;
  final String time;

  DashboardAlert({
    required this.id,
    required this.message,
    required this.vehicleId,
    required this.severity,
    required this.time,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    return DashboardAlert(
      id: json['id']?.toString() ?? '',
      message: json['message'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      severity: json['severity'] ?? 'warning',
      time: json['time'] ?? '',
    );
  }
}
