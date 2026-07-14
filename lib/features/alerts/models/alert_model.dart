// Model for alert data from the DravYantra backend
class AlertModel {
  final int id;
  final String? uid;
  final String? tripId;
  final String? vehiclePlate;
  final String? driver;
  final String? deviceId;
  final String type;
  final String message;
  final String severity;
  final String? category;
  final String status;
  final String? priority;
  final String? source;
  final double? lat;
  final double? lng;
  final bool notifiedFleetOwner;
  final String? adminNotes;
  final String? organizationName;
  final String? fleetOwnerName;
  final String? fleetOwnerEmail;
  final DateTime detectedAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final DateTime? dismissedAt;
  final List<AuditLogEntry> auditLog;

  AlertModel({
    required this.id,
    this.uid,
    this.tripId,
    this.vehiclePlate,
    this.driver,
    this.deviceId,
    required this.type,
    required this.message,
    required this.severity,
    this.category,
    required this.status,
    this.priority,
    this.source,
    this.lat,
    this.lng,
    this.notifiedFleetOwner = false,
    this.adminNotes,
    this.organizationName,
    this.fleetOwnerName,
    this.fleetOwnerEmail,
    required this.detectedAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.dismissedAt,
    this.auditLog = const [],
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      uid: json['uid'],
      tripId: json['trip_id'],
      vehiclePlate: json['vehicle_plate'],
      driver: json['driver'],
      deviceId: json['device_id'],
      type: json['type'] ?? 'Unknown',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'Medium',
      category: json['category'],
      status: json['status'] ?? 'New',
      priority: json['priority'] ?? 'Medium',
      source: json['source'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      notifiedFleetOwner: json['notified_fleet_owner'] == true,
      adminNotes: json['admin_notes'],
      organizationName: json['organization_name'],
      fleetOwnerName: json['fleet_owner_name'],
      fleetOwnerEmail: json['fleet_owner_email'],
      detectedAt: json['detected_at'] != null
          ? DateTime.tryParse(json['detected_at']) ?? DateTime.now()
          : DateTime.now(),
      acknowledgedAt: json['acknowledged_at'] != null ? DateTime.tryParse(json['acknowledged_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at']) : null,
      dismissedAt: json['dismissed_at'] != null ? DateTime.tryParse(json['dismissed_at']) : null,
      auditLog: (json['auditLog'] as List<dynamic>?)
              ?.map((e) => AuditLogEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AuditLogEntry {
  final int id;
  final String? adminUid;
  final String action;
  final String? details;
  final DateTime createdAt;

  AuditLogEntry({
    required this.id,
    this.adminUid,
    required this.action,
    this.details,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] ?? 0,
      adminUid: json['admin_uid'],
      action: json['action'] ?? '',
      details: json['details'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AlertStatistics {
  final int criticalToday;
  final int fuelTheftToday;
  final int overspeedToday;
  final int offlineDevices;
  final int offlineVehicles;
  final int pendingAlerts;
  final int resolvedToday;
  final int totalToday;
  final double avgResolutionMinutes;
  final List<Map<String, dynamic>> bySeverity;
  final List<Map<String, dynamic>> byType;
  final List<Map<String, dynamic>> byOrganization;

  AlertStatistics({
    required this.criticalToday,
    required this.fuelTheftToday,
    required this.overspeedToday,
    required this.offlineDevices,
    required this.offlineVehicles,
    required this.pendingAlerts,
    required this.resolvedToday,
    required this.totalToday,
    required this.avgResolutionMinutes,
    required this.bySeverity,
    required this.byType,
    required this.byOrganization,
  });

  factory AlertStatistics.fromJson(Map<String, dynamic> json) {
    return AlertStatistics(
      criticalToday: int.tryParse(json['criticalToday']?.toString() ?? '0') ?? 0,
      fuelTheftToday: int.tryParse(json['fuelTheftToday']?.toString() ?? '0') ?? 0,
      overspeedToday: int.tryParse(json['overspeedToday']?.toString() ?? '0') ?? 0,
      offlineDevices: int.tryParse(json['offlineDevices']?.toString() ?? '0') ?? 0,
      offlineVehicles: int.tryParse(json['offlineVehicles']?.toString() ?? '0') ?? 0,
      pendingAlerts: int.tryParse(json['pendingAlerts']?.toString() ?? '0') ?? 0,
      resolvedToday: int.tryParse(json['resolvedToday']?.toString() ?? '0') ?? 0,
      totalToday: int.tryParse(json['totalToday']?.toString() ?? '0') ?? 0,
      avgResolutionMinutes: double.tryParse(json['avgResolutionMinutes']?.toString() ?? '0') ?? 0,
      bySeverity: (json['bySeverity'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
      byType: (json['byType'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
      byOrganization: (json['byOrganization'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }
}
