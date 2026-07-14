// features/authentication/models/auth_model.dart

class AdminUser {
  final String uid;
  final String email;
  final String fullName;
  final String role;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    uid:      json['uid']       ?? '',
    email:    json['email']     ?? '',
    fullName: json['full_name'] ?? '',
    role:     json['role']      ?? 'fleet_owner',
  );

  Map<String, dynamic> toJson() => {
    'uid': uid, 'email': email, 'full_name': fullName, 'role': role,
  };

  bool get isAdmin => role == 'admin';
}
