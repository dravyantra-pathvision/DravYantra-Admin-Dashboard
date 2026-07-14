class DriverModel {
  final String id;
  final String uid; // Fleet Owner UID
  final String name;
  final String? phone;
  final String? lic;
  final String? licExp;
  final String? vehicle;
  final String status; // 'Active', 'Suspended', etc
  final String? ownerName;
  final String? ownerEmail;
  final String? companyName;
  final bool isActive;
  final bool onLeave;
  final DateTime? createdAt;
  final List<dynamic> auditLogs;
  // Detail fields
  final String? blood;
  final int? age;
  final int? exp;
  final int? score;
  final double? mil;
  final double? idle;
  final int? trips;
  final int? harsh;
  final int? overSpeed;
  final int? deviation;
  final int? fuelEff;
  final double? rating;
  final String? home;
  final List<dynamic>? tripHistory;
  final String? imageUrl;
  final String? aadharUrl;
  final String? licenseUrl;

  DriverModel({
    required this.id,
    required this.uid,
    required this.name,
    this.phone,
    this.lic,
    this.licExp,
    this.vehicle,
    required this.status,
    this.ownerName,
    this.ownerEmail,
    this.companyName,
    this.isActive = true,
    this.onLeave = false,
    this.createdAt,
    this.auditLogs = const [],
    this.blood,
    this.age,
    this.exp,
    this.score,
    this.mil,
    this.idle,
    this.trips,
    this.harsh,
    this.overSpeed,
    this.deviation,
    this.fuelEff,
    this.rating,
    this.home,
    this.tripHistory,
    this.imageUrl,
    this.aadharUrl,
    this.licenseUrl,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Unknown',
      phone: json['phone'],
      lic: json['lic'],
      licExp: json['lic_exp'],
      vehicle: json['vehicle'],
      status: json['status'] ?? 'Active',
      ownerName: json['owner_name'],
      ownerEmail: json['owner_email'],
      companyName: json['company_name'],
      isActive: json['is_active'] ?? true,
      onLeave: json['on_leave'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      auditLogs: json['auditLogs'] ?? [],
      blood: json['blood'],
      age: json['age'],
      exp: json['exp'],
      score: json['score'],
      mil: json['mil'] != null ? (json['mil'] as num).toDouble() : null,
      idle: json['idle'] != null ? (json['idle'] as num).toDouble() : null,
      trips: json['trips'],
      harsh: json['harsh'],
      overSpeed: json['over_speed'],
      deviation: json['deviation'],
      fuelEff: json['fuel_eff'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      home: json['home'],
      tripHistory: json['trip_history'],
      imageUrl: json['image_url'],
      aadharUrl: json['aadhar_url'],
      licenseUrl: json['license_url'],
    );
  }

  bool get isLicenseExpiringSoon {
    if (licExp == null) return false;
    try {
      final parts = licExp!.split('-');
      if (parts.length != 3) return false;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final expDate = DateTime(year, month, day);
      final daysUntilExp = expDate.difference(DateTime.now()).inDays;
      // You specified 30 days threshold in the implementation plan
      return daysUntilExp >= 0 && daysUntilExp <= 30;
    } catch (e) {
      return false;
    }
  }

  bool get isLicenseExpired {
    if (licExp == null) return false;
    try {
      final parts = licExp!.split('-');
      if (parts.length != 3) return false;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final expDate = DateTime(year, month, day);
      final daysUntilExp = expDate.difference(DateTime.now()).inDays;
      return daysUntilExp < 0;
    } catch (e) {
      return false;
    }
  }
}
