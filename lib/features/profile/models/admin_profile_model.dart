class AdminProfile {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final DateTime? createdAt;
  final String? phone;
  final String? timezone;
  final String? employeeId;
  final String? department;
  final String? languagePref;
  final String? accountStatus;
  final String? profilePhoto;
  final String? designation;
  final Map<String, dynamic>? notificationPreferences;
  final DateTime? lastLogin;

  AdminProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.createdAt,
    this.phone,
    this.timezone,
    this.employeeId,
    this.department,
    this.languagePref,
    this.accountStatus,
    this.profilePhoto,
    this.designation,
    this.notificationPreferences,
    this.lastLogin,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      phone: json['phone'],
      timezone: json['timezone'],
      employeeId: json['employee_id'],
      department: json['department'],
      languagePref: json['language_pref'],
      accountStatus: json['account_status'],
      profilePhoto: json['profile_photo'],
      designation: json['designation'],
      notificationPreferences: json['notification_preferences'],
      lastLogin: json['last_login'] != null ? DateTime.tryParse(json['last_login']) : null,
    );
  }
}

class AdminSession {
  final int id;
  final String ipAddress;
  final String userAgent;
  final String browser;
  final String os;
  final String device;
  final DateTime? loginTime;
  final DateTime? lastActiveTime;
  final bool isActive;

  AdminSession({
    required this.id,
    required this.ipAddress,
    required this.userAgent,
    required this.browser,
    required this.os,
    required this.device,
    this.loginTime,
    this.lastActiveTime,
    required this.isActive,
  });

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      id: json['id'] ?? 0,
      ipAddress: json['ip_address'] ?? 'Unknown',
      userAgent: json['user_agent'] ?? 'Unknown',
      browser: json['browser'] ?? 'Unknown',
      os: json['os'] ?? 'Unknown',
      device: json['device'] ?? 'Unknown',
      loginTime: json['login_time'] != null ? DateTime.tryParse(json['login_time']) : null,
      lastActiveTime: json['last_active_time'] != null ? DateTime.tryParse(json['last_active_time']) : null,
      isActive: json['is_active'] ?? false,
    );
  }
}
