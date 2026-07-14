class Trip {
  final String id;
  final String? uid;
  final String? vehicle;
  final String? driver;
  final String? fromLocation;
  final String? toLocation;
  final String? load;
  final String? client;
  final String? status;
  final bool? tripCompleted;
  final String? ewayBill;
  final String? ewayBillUrl;
  final String? date;
  final double? progress;
  final double? distance;
  final double? fuelUsed;
  final double? score;
  final int? delayMinutes;
  final List<dynamic>? waypoints;
  final int? tollCount;
  final double? liveSpeed;
  final bool? power;
  final int? idleDuration;
  final double? defaultMileage;
  final double? currentMileage;
  final double? fuelSaved;
  final double? fuelWasted;
  final double? moneySaved;
  final double? moneyWasted;
  final double? idleMoneyWasted;
  final double? fuelPrice;
  final double? fuelPricePerLiter;
  final double? liveIdleSpeed;
  final String? liveIdleTime;
  final int? totalIdleTime;
  final double? liveFuelCount;
  final double? speedingFuelWasted;
  final double? theftFuelLoss;
  final double? theftMoneyLoss;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  
  // Relational data
  final String? fleetOwnerEmail;
  final String? fleetOwnerName;
  final String? fleetOwnerPhone;
  final String? organizationName;

  Trip({
    required this.id,
    this.uid,
    this.vehicle,
    this.driver,
    this.fromLocation,
    this.toLocation,
    this.load,
    this.client,
    this.status,
    this.tripCompleted,
    this.ewayBill,
    this.ewayBillUrl,
    this.date,
    this.progress,
    this.distance,
    this.fuelUsed,
    this.score,
    this.delayMinutes,
    this.waypoints,
    this.tollCount,
    this.liveSpeed,
    this.power,
    this.idleDuration,
    this.defaultMileage,
    this.currentMileage,
    this.fuelSaved,
    this.fuelWasted,
    this.moneySaved,
    this.moneyWasted,
    this.idleMoneyWasted,
    this.fuelPrice,
    this.fuelPricePerLiter,
    this.liveIdleSpeed,
    this.liveIdleTime,
    this.totalIdleTime,
    this.liveFuelCount,
    this.speedingFuelWasted,
    this.theftFuelLoss,
    this.theftMoneyLoss,
    this.updatedAt,
    this.createdAt,
    this.fleetOwnerEmail,
    this.fleetOwnerName,
    this.fleetOwnerPhone,
    this.organizationName,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      uid: json['uid'],
      vehicle: json['vehicle'],
      driver: json['driver'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      load: json['load'],
      client: json['client'],
      status: json['status'],
      tripCompleted: json['trip_completed'] == true || json['trip_completed'] == 'true',
      ewayBill: json['eway_bill'],
      ewayBillUrl: json['eway_bill_url'],
      date: json['date'],
      progress: json['progress'] != null ? double.tryParse(json['progress'].toString()) : null,
      distance: json['distance'] != null ? double.tryParse(json['distance'].toString()) : null,
      fuelUsed: json['fuel_used'] != null ? double.tryParse(json['fuel_used'].toString()) : null,
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      delayMinutes: json['delay_minutes'] != null ? int.tryParse(json['delay_minutes'].toString()) : null,
      waypoints: json['waypoints'] is List ? json['waypoints'] : [],
      tollCount: json['toll_count'] != null ? int.tryParse(json['toll_count'].toString()) : null,
      liveSpeed: json['live_speed'] != null ? double.tryParse(json['live_speed'].toString()) : null,
      power: json['power'] == true || json['power'] == 'true',
      idleDuration: json['idle_duration'] != null ? int.tryParse(json['idle_duration'].toString()) : null,
      defaultMileage: json['default_mileage'] != null ? double.tryParse(json['default_mileage'].toString()) : null,
      currentMileage: json['current_mileage'] != null ? double.tryParse(json['current_mileage'].toString()) : null,
      fuelSaved: json['fuel_saved'] != null ? double.tryParse(json['fuel_saved'].toString()) : null,
      fuelWasted: json['fuel_wasted'] != null ? double.tryParse(json['fuel_wasted'].toString()) : null,
      moneySaved: json['money_saved'] != null ? double.tryParse(json['money_saved'].toString()) : null,
      moneyWasted: json['money_wasted'] != null ? double.tryParse(json['money_wasted'].toString()) : null,
      idleMoneyWasted: json['idle_money_wasted'] != null ? double.tryParse(json['idle_money_wasted'].toString()) : null,
      fuelPrice: json['fuel_price'] != null ? double.tryParse(json['fuel_price'].toString()) : null,
      fuelPricePerLiter: json['fuel_price_per_liter'] != null ? double.tryParse(json['fuel_price_per_liter'].toString()) : null,
      liveIdleSpeed: json['live_idle_speed'] != null ? double.tryParse(json['live_idle_speed'].toString()) : null,
      liveIdleTime: json['live_idle_time'],
      totalIdleTime: json['total_idle_time'] != null ? int.tryParse(json['total_idle_time'].toString()) : null,
      liveFuelCount: json['live_fuel_count'] != null ? double.tryParse(json['live_fuel_count'].toString()) : null,
      speedingFuelWasted: json['speeding_fuel_wasted'] != null ? double.tryParse(json['speeding_fuel_wasted'].toString()) : null,
      theftFuelLoss: json['theft_fuel_loss'] != null ? double.tryParse(json['theft_fuel_loss'].toString()) : null,
      theftMoneyLoss: json['theft_money_loss'] != null ? double.tryParse(json['theft_money_loss'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      fleetOwnerEmail: json['fleet_owner_email'],
      fleetOwnerName: json['fleet_owner_name'],
      fleetOwnerPhone: json['fleet_owner_phone'],
      organizationName: json['organization_name'],
    );
  }
}
