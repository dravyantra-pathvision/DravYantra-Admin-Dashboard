// app/constants.dart
// App-wide constants, enums, and design tokens.

class AppConstants {
  AppConstants._();

  static const String appName     = 'DravYantra Admin';
  static const String appVersion  = '1.0.0';
  static const String companyName = 'Pathvision Innovations';

  // Token storage key
  static const String tokenKey    = 'dy_admin_token';
  static const String roleKey     = 'dy_admin_role';
  static const String userKey     = 'dy_admin_user';

  // API
  static const String apiBaseUrl  = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://16.112.99.7:3000',
  );

  // Session
  static const int sessionHours = 24;

  // Pagination
  static const int defaultPageSize = 50;

  // Sidebar width
  static const double sidebarWidth        = 240;
  static const double sidebarCollapsed    = 64;
}

enum UserRole { admin, fleetOwner, unknown }

extension UserRoleExt on UserRole {
  static UserRole fromString(String? role) {
    switch (role) {
      case 'admin':       return UserRole.admin;
      case 'fleet_owner': return UserRole.fleetOwner;
      default:            return UserRole.unknown;
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin:      return 'Admin';
      case UserRole.fleetOwner: return 'Fleet Owner';
      case UserRole.unknown:    return 'Unknown';
    }
  }
}
