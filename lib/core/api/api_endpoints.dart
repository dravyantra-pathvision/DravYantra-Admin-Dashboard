// core/api/api_endpoints.dart
// Single source of truth for all backend API endpoint strings.

import '../../../app/constants.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get base => AppConstants.apiBaseUrl;

  // ── Auth ────────────────────────────────────────────────────────────────────
  static String get login     => '$base/api/admin/login';

  // ── Admin — Dashboard ───────────────────────────────────────────────────────
  static String get dashboard => '$base/api/admin/dashboard';

  // ── Admin — Profile ─────────────────────────────────────────────────────────
  static String get profile => '$base/api/admin/profile';
  static String get profilePassword => '$base/api/admin/profile/password';
  static String get profilePhoto => '$base/api/admin/profile/photo';
  static String get profileSessions => '$base/api/admin/profile/sessions';
  static String profileSession(String id) => '$base/api/admin/profile/sessions/$id';
  static String get profileNotifications => '$base/api/admin/profile/notifications';


  // ── Admin — Fleet Owners ─────────────────────────────────────────────────────
  static String get fleetOwners        => '$base/api/admin/fleetowners';

  // ── Admin — Organizations ────────────────────────────────────────────────────
  static String get organizations               => '$base/api/admin/organizations';
  static String organization(String uid)        => '$base/api/admin/organizations/$uid';

  // ── Admin — Vehicles ────────────────────────────────────────────────────────
  static String get vehicles           => '$base/api/admin/vehicles';
  static String vehicle(String id)     => '$base/api/admin/vehicles/$id';
  static String vehicleStatus(String id) => '$base/api/admin/vehicles/$id/status';

  // ── Admin — Drivers ─────────────────────────────────────────────────────────
  static String get drivers            => '$base/api/admin/drivers';

  // ── Admin — Trips ───────────────────────────────────────────────────────────
  static String get trips              => '$base/api/admin/trips';

  // ── Admin — Alerts ──────────────────────────────────────────────────────────
  static String get alerts             => '$base/api/admin/alerts';

  // ── Admin — Reports ─────────────────────────────────────────────────────────
  static String get reports            => '$base/api/admin/reports';

  // ── Admin — Analytics ───────────────────────────────────────────────────────
  static String get analytics          => '$base/api/admin/analytics';

  // ── Admin — Settings ────────────────────────────────────────────────────────
  static String get settings           => '$base/api/admin/settings';
  static String get settingsHistory    => '$base/api/admin/settings/history';
  static String setting(String key)    => '$base/api/admin/settings/$key';

  // ── Admin — Live Monitoring ──────────────────────────────────────────────────
  static String get liveDashboard      => '$base/api/admin/live-dashboard';
  static String get liveVehicles       => '$base/api/admin/live-vehicles';
  static String liveVehicle(String id) => '$base/api/admin/live-vehicle/$id';
  static String get liveAlerts         => '$base/api/admin/live-alerts';
  static String get liveStatistics     => '$base/api/admin/live-statistics';
  static String get liveFleetList      => '$base/api/admin/live-fleet-list';

  // ── Admin — Activity Logs ────────────────────────────────────────────────────
  static String get activityLogs       => '$base/api/admin/activity-logs';

  // ── Admin — Alerts & Incident Management ─────────────────────────────────────
  static String get alertStatistics    => '$base/api/admin/alerts/statistics';
  static String get alertFilterOptions => '$base/api/admin/alerts/filter-options';
  static String alertById(int id)      => '$base/api/admin/alerts/$id';
  static String alertStatus(int id)    => '$base/api/admin/alerts/$id/status';
  static String alertComment(int id)   => '$base/api/admin/alerts/$id/comment';
  static String alertNotify(int id)    => '$base/api/admin/alerts/$id/notify';

  // ── Admin — Support & Tickets ───────────────────────────────────────────────────
  static String get supportAnalytics   => '$base/api/admin/support/analytics';
  static String get supportTickets     => '$base/api/admin/support/tickets';
  static String supportTicket(String n)=> '$base/api/admin/support/tickets/$n';
  static String ticketMessages(String n)=> '$base/api/admin/support/tickets/$n/messages';

  // ── Admin — Subscriptions & Billing ─────────────────────────────────────────
  static String get subscriptionDashboard    => '$base/api/admin/subscriptions/dashboard';
  static String get subscriptionPlans        => '$base/api/admin/subscriptions/plans';
  static String subscriptionPlan(int id)     => '$base/api/admin/subscriptions/plans/$id';
  static String get subscriptions            => '$base/api/admin/subscriptions';
  static String subscriptionByOrg(String uid)=> '$base/api/admin/subscriptions/org/$uid';
  static String get subscriptionAssign       => '$base/api/admin/subscriptions/assign';
  static String subscriptionAction(int id, String action) => '$base/api/admin/subscriptions/$id/$action';
  static String get subscriptionInvoices     => '$base/api/admin/subscriptions/invoices';
  static String get subscriptionInvoiceGenerate => '$base/api/admin/subscriptions/invoices/generate';
  static String subscriptionInvoice(int id)  => '$base/api/admin/subscriptions/invoices/$id';
  static String subscriptionInvoicePay(int id) => '$base/api/admin/subscriptions/invoices/$id/pay';
  static String get subscriptionPayments     => '$base/api/admin/subscriptions/payments';
}

