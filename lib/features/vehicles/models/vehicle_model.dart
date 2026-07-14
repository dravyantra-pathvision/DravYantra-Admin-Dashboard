class Vehicle {
  final String plate;
  final String uid;
  final String? make;
  final String? model;
  final int? year;
  final String? type;
  final String? fuelType;
  final double? fuelCapacity;
  final String? vin;
  final String? engineNumber;
  final String? chassisNumber;
  final int? odo;
  final String? status;
  final DateTime? rcExpiry;
  final DateTime? insuranceExpiry;
  final DateTime? pucExpiry;
  final DateTime? fitnessExpiry;
  final String? deviceId;
  final int? driver;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relational data
  final String? fleetOwnerName;
  final String? fleetOwnerEmail;
  final String? fleetOwnerPhone;
  final String? organizationName;
  final String? driverName;
  final String? driverPhone;
  final String? deviceStatus;
  final DateTime? lastCommunication;
  
  // Telemetry data
  final double? speed;
  final double? fuel;
  final double? lat;
  final double? lng;

  Vehicle({
    required this.plate,
    required this.uid,
    this.make,
    this.model,
    this.year,
    this.type,
    this.fuelType,
    this.fuelCapacity,
    this.vin,
    this.engineNumber,
    this.chassisNumber,
    this.odo,
    this.status,
    this.rcExpiry,
    this.insuranceExpiry,
    this.pucExpiry,
    this.fitnessExpiry,
    this.deviceId,
    this.driver,
    this.createdAt,
    this.updatedAt,
    this.fleetOwnerName,
    this.fleetOwnerEmail,
    this.fleetOwnerPhone,
    this.organizationName,
    this.driverName,
    this.driverPhone,
    this.deviceStatus,
    this.lastCommunication,
    this.speed,
    this.fuel,
    this.lat,
    this.lng,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      plate: json['plate'] ?? '',
      uid: json['uid'] ?? '',
      make: json['make'],
      model: json['model'],
      year: json['year'] != null ? int.tryParse(json['year'].toString()) : null,
      type: json['type'],
      fuelType: json['fuel_type'],
      fuelCapacity: json['fuel_capacity'] != null ? double.tryParse(json['fuel_capacity'].toString()) : null,
      vin: json['vin'],
      engineNumber: json['engine_number'],
      chassisNumber: json['chassis_number'],
      odo: json['odo'] != null ? int.tryParse(json['odo'].toString()) : null,
      status: json['status'],
      rcExpiry: json['rc_expiry'] != null ? DateTime.tryParse(json['rc_expiry']) : null,
      insuranceExpiry: json['insurance_expiry'] != null ? DateTime.tryParse(json['insurance_expiry']) : null,
      pucExpiry: json['puc_expiry'] != null ? DateTime.tryParse(json['puc_expiry']) : null,
      fitnessExpiry: json['fitness_expiry'] != null ? DateTime.tryParse(json['fitness_expiry']) : null,
      deviceId: json['device_id'],
      driver: json['driver'] != null && json['driver'].toString().toLowerCase() != 'unassigned' ? int.tryParse(json['driver'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      fleetOwnerName: json['fleet_owner_name'],
      fleetOwnerEmail: json['fleet_owner_email'],
      fleetOwnerPhone: json['fleet_owner_phone'],
      organizationName: json['organization_name'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      deviceStatus: json['device_status'],
      lastCommunication: json['last_communication'] != null ? DateTime.tryParse(json['last_communication']) : null,
      speed: json['speed'] != null ? double.tryParse(json['speed'].toString()) : null,
      fuel: json['fuel'] != null ? double.tryParse(json['fuel'].toString()) : null,
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
    );
  }
}

class VehicleAuditLog {
  final int id;
  final String vehiclePlate;
  final String action;
  final String? adminId;
  final String? reason;
  final String? remarks;
  final DateTime createdAt;
  final String? adminName;
  final String? adminEmail;

  VehicleAuditLog({
    required this.id,
    required this.vehiclePlate,
    required this.action,
    this.adminId,
    this.reason,
    this.remarks,
    required this.createdAt,
    this.adminName,
    this.adminEmail,
  });

  factory VehicleAuditLog.fromJson(Map<String, dynamic> json) {
    return VehicleAuditLog(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      vehiclePlate: json['vehicle_plate'] ?? '',
      action: json['action'] ?? '',
      adminId: json['admin_id'],
      reason: json['reason'],
      remarks: json['remarks'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      adminName: json['admin_name'],
      adminEmail: json['admin_email'],
    );
  }
}
