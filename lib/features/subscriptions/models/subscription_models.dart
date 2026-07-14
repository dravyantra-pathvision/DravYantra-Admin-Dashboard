// Subscription & Billing data models.

class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String planType;
  final String billingCycle;
  final double price;
  final String currency;
  final int trialDays;
  final int maxVehicles;
  final int maxDrivers;
  final double maxStorageGb;
  final bool isActive;
  final bool isCustom;
  final int sortOrder;
  final List<PlanFeature> features;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.planType = 'paid',
    this.billingCycle = 'monthly',
    this.price = 0,
    this.currency = 'INR',
    this.trialDays = 0,
    this.maxVehicles = 0,
    this.maxDrivers = 0,
    this.maxStorageGb = 1,
    this.isActive = true,
    this.isCustom = false,
    this.sortOrder = 0,
    this.features = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      planType: json['plan_type'] ?? 'paid',
      billingCycle: json['billing_cycle'] ?? 'monthly',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      currency: json['currency'] ?? 'INR',
      trialDays: json['trial_days'] ?? 0,
      maxVehicles: json['max_vehicles'] ?? 0,
      maxDrivers: json['max_drivers'] ?? 0,
      maxStorageGb: double.tryParse(json['max_storage_gb']?.toString() ?? '1') ?? 1,
      isActive: json['is_active'] ?? true,
      isCustom: json['is_custom'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      features: (json['features'] as List?)?.map((f) => PlanFeature.fromJson(f)).toList() ?? [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'slug': slug, 'description': description,
    'plan_type': planType, 'billing_cycle': billingCycle, 'price': price,
    'trial_days': trialDays, 'max_vehicles': maxVehicles, 'max_drivers': maxDrivers,
    'max_storage_gb': maxStorageGb, 'is_custom': isCustom, 'sort_order': sortOrder,
    'features': features.map((f) => f.toJson()).toList(),
  };

  String get displayPrice {
    if (planType == 'trial') return 'Free';
    if (isCustom) return 'Custom';
    return '₹${price.toStringAsFixed(0)}';
  }

  String get displayBillingCycle {
    if (planType == 'trial') return '${trialDays} days';
    if (billingCycle == 'monthly') return '/mo';
    if (billingCycle == 'annual') return '/yr';
    return '';
  }
}

class PlanFeature {
  final int? id;
  final String featureKey;
  final String featureLabel;
  final bool isEnabled;
  final String? featureLimit;

  PlanFeature({
    this.id,
    required this.featureKey,
    required this.featureLabel,
    this.isEnabled = true,
    this.featureLimit,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) => PlanFeature(
    id: json['id'],
    featureKey: json['feature_key'] ?? '',
    featureLabel: json['feature_label'] ?? '',
    isEnabled: json['is_enabled'] ?? true,
    featureLimit: json['feature_limit'],
  );

  Map<String, dynamic> toJson() => {
    'feature_key': featureKey, 'feature_label': featureLabel,
    'is_enabled': isEnabled, 'feature_limit': featureLimit,
  };
}

class OrganizationSubscription {
  final int id;
  final String orgUid;
  final int? planId;
  final String status;
  final DateTime? startedAt;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? renewedAt;
  final DateTime? cancelledAt;
  final DateTime? suspendedAt;
  final String? suspensionReason;
  final int vehiclesUsed;
  final int driversUsed;
  final double storageUsedGb;
  final bool autoRenew;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? planName;
  final String? planSlug;
  final double? planPrice;
  final String? billingCycle;
  final int? maxVehicles;
  final int? maxDrivers;
  final double? maxStorageGb;
  final String? orgName;
  final String? orgCity;
  final String? orgState;
  final String? orgEmail;
  final String? ownerName;
  final int? actualVehicles;
  final int? actualDrivers;
  final List<PlanFeature> features;

  OrganizationSubscription({
    required this.id,
    required this.orgUid,
    this.planId,
    this.status = 'trial',
    this.startedAt,
    this.trialEndsAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.renewedAt,
    this.cancelledAt,
    this.suspendedAt,
    this.suspensionReason,
    this.vehiclesUsed = 0,
    this.driversUsed = 0,
    this.storageUsedGb = 0,
    this.autoRenew = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.planName,
    this.planSlug,
    this.planPrice,
    this.billingCycle,
    this.maxVehicles,
    this.maxDrivers,
    this.maxStorageGb,
    this.orgName,
    this.orgCity,
    this.orgState,
    this.orgEmail,
    this.ownerName,
    this.actualVehicles,
    this.actualDrivers,
    this.features = const [],
  });

  factory OrganizationSubscription.fromJson(Map<String, dynamic> json) {
    return OrganizationSubscription(
      id: json['id'],
      orgUid: json['org_uid'] ?? '',
      planId: json['plan_id'],
      status: json['status'] ?? 'trial',
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null,
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.tryParse(json['trial_ends_at'].toString()) : null,
      currentPeriodStart: json['current_period_start'] != null ? DateTime.tryParse(json['current_period_start'].toString()) : null,
      currentPeriodEnd: json['current_period_end'] != null ? DateTime.tryParse(json['current_period_end'].toString()) : null,
      renewedAt: json['renewed_at'] != null ? DateTime.tryParse(json['renewed_at'].toString()) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.tryParse(json['cancelled_at'].toString()) : null,
      suspendedAt: json['suspended_at'] != null ? DateTime.tryParse(json['suspended_at'].toString()) : null,
      suspensionReason: json['suspension_reason'],
      vehiclesUsed: json['vehicles_used'] ?? 0,
      driversUsed: json['drivers_used'] ?? 0,
      storageUsedGb: double.tryParse(json['storage_used_gb']?.toString() ?? '0') ?? 0,
      autoRenew: json['auto_renew'] ?? true,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      planName: json['plan_name'],
      planSlug: json['plan_slug'],
      planPrice: double.tryParse(json['plan_price']?.toString() ?? '0'),
      billingCycle: json['billing_cycle'],
      maxVehicles: json['max_vehicles'],
      maxDrivers: json['max_drivers'],
      maxStorageGb: double.tryParse(json['max_storage_gb']?.toString() ?? '0'),
      orgName: json['org_name'],
      orgCity: json['org_city'],
      orgState: json['org_state'],
      orgEmail: json['org_email'],
      ownerName: json['owner_name'],
      actualVehicles: int.tryParse(json['actual_vehicles']?.toString() ?? '0'),
      actualDrivers: int.tryParse(json['actual_drivers']?.toString() ?? '0'),
      features: (json['features'] as List?)?.map((f) => PlanFeature.fromJson(f)).toList() ?? [],
    );
  }
}

class SubscriptionInvoice {
  final int id;
  final String invoiceNumber;
  final int? subscriptionId;
  final String orgUid;
  final int? planId;
  final double amount;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final String status;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? notes;
  final DateTime? createdAt;

  // Joined
  final String? planName;
  final String? orgName;
  final String? orgEmail;

  SubscriptionInvoice({
    required this.id,
    required this.invoiceNumber,
    this.subscriptionId,
    required this.orgUid,
    this.planId,
    this.amount = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.currency = 'INR',
    this.status = 'pending',
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.dueDate,
    this.paidAt,
    this.notes,
    this.createdAt,
    this.planName,
    this.orgName,
    this.orgEmail,
  });

  factory SubscriptionInvoice.fromJson(Map<String, dynamic> json) {
    return SubscriptionInvoice(
      id: json['id'],
      invoiceNumber: json['invoice_number'] ?? '',
      subscriptionId: json['subscription_id'],
      orgUid: json['org_uid'] ?? '',
      planId: json['plan_id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? 'pending',
      billingPeriodStart: json['billing_period_start'] != null ? DateTime.tryParse(json['billing_period_start'].toString()) : null,
      billingPeriodEnd: json['billing_period_end'] != null ? DateTime.tryParse(json['billing_period_end'].toString()) : null,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'].toString()) : null,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      planName: json['plan_name'],
      orgName: json['org_name'],
      orgEmail: json['org_email'],
    );
  }
}

class SubscriptionDashboardStats {
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int trialSubscriptions;
  final int suspendedSubscriptions;
  final int expiredSubscriptions;
  final double mrr;
  final double totalRevenue;
  final double pendingRevenue;
  final int pendingInvoices;
  final int paidInvoices;
  final List<PlanDistribution> planDistribution;
  final List<AuditEntry> recentActivity;

  SubscriptionDashboardStats({
    this.totalSubscriptions = 0,
    this.activeSubscriptions = 0,
    this.trialSubscriptions = 0,
    this.suspendedSubscriptions = 0,
    this.expiredSubscriptions = 0,
    this.mrr = 0,
    this.totalRevenue = 0,
    this.pendingRevenue = 0,
    this.pendingInvoices = 0,
    this.paidInvoices = 0,
    this.planDistribution = const [],
    this.recentActivity = const [],
  });

  factory SubscriptionDashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['statistics'] ?? {};
    return SubscriptionDashboardStats(
      totalSubscriptions: stats['totalSubscriptions'] ?? 0,
      activeSubscriptions: stats['activeSubscriptions'] ?? 0,
      trialSubscriptions: stats['trialSubscriptions'] ?? 0,
      suspendedSubscriptions: stats['suspendedSubscriptions'] ?? 0,
      expiredSubscriptions: stats['expiredSubscriptions'] ?? 0,
      mrr: (stats['mrr'] ?? 0).toDouble(),
      totalRevenue: (stats['totalRevenue'] ?? 0).toDouble(),
      pendingRevenue: (stats['pendingRevenue'] ?? 0).toDouble(),
      pendingInvoices: stats['pendingInvoices'] ?? 0,
      paidInvoices: stats['paidInvoices'] ?? 0,
      planDistribution: (json['planDistribution'] as List?)?.map((e) => PlanDistribution.fromJson(e)).toList() ?? [],
      recentActivity: (json['recentActivity'] as List?)?.map((e) => AuditEntry.fromJson(e)).toList() ?? [],
    );
  }
}

class PlanDistribution {
  final String name;
  final String slug;
  final int count;

  PlanDistribution({required this.name, required this.slug, this.count = 0});

  factory PlanDistribution.fromJson(Map<String, dynamic> json) => PlanDistribution(
    name: json['name'] ?? '',
    slug: json['slug'] ?? '',
    count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
  );
}

class AuditEntry {
  final int id;
  final String action;
  final String? orgName;
  final Map<String, dynamic> details;
  final DateTime? createdAt;

  AuditEntry({required this.id, required this.action, this.orgName, this.details = const {}, this.createdAt});

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
    id: json['id'],
    action: json['action'] ?? '',
    orgName: json['org_name'],
    details: json['details'] is Map ? Map<String, dynamic>.from(json['details']) : {},
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
  );
}
