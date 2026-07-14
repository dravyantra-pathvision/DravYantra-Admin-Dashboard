// app/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/authentication/providers/auth_provider.dart';
import '../features/authentication/screens/admin_login_screen.dart';
import '../shared/components/admin_shell.dart';
import '../shared/widgets/placeholder_screen.dart';
import '../features/subscriptions/screens/subscriptions_screen.dart';
import '../features/support/screens/support_dashboard_screen.dart';
import '../features/support/screens/ticket_detail_screen.dart';
import '../features/audit/screens/audit_dashboard_screen.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/live/screens/live_fleet_screen.dart';
import '../features/organizations/screens/organizations_screen.dart';
import '../features/fleet_owners/screens/fleet_owners_screen.dart';
import '../features/devices/screens/devices_screen.dart';
import '../features/vehicles/screens/vehicles_screen.dart';
import '../features/vehicles/screens/vehicle_detail_screen.dart';
import '../features/drivers/screens/drivers_screen.dart';
import '../features/drivers/screens/driver_detail_screen.dart';
import '../features/trips/screens/trips_screen.dart';
import '../features/trips/screens/trip_detail_screen.dart';
import '../features/alerts/screens/alerts_screen.dart';
import '../features/analytics/screens/analytics_dashboard_screen.dart';
import '../features/reports/screens/reports_dashboard_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/support/screens/support_dashboard_screen.dart';
import '../features/support/screens/ticket_detail_screen.dart';
import '../features/profile/screens/admin_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/live',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LiveFleetScreen(),
            ),
          ),
          GoRoute(
            path: '/organizations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrganizationsScreen(),
            ),
          ),
          GoRoute(
            path: '/fleet-owners',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FleetOwnersScreen(),
            ),
          ),
          GoRoute(
            path: '/vehicles',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VehiclesScreen(),
            ),
          ),
          GoRoute(
            path: '/vehicles/:plate',
            builder: (context, state) => VehicleDetailScreen(
              plate: state.pathParameters['plate']!,
            ),
          ),
          GoRoute(
            path: '/drivers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DriversScreen(),
            ),
          ),
          GoRoute(
            path: '/drivers/:id',
            builder: (context, state) => DriverDetailScreen(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/devices',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DevicesScreen(),
            ),
          ),
          GoRoute(
            path: '/trips',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TripsScreen(),
            ),
          ),
          GoRoute(
            path: '/trips/:id',
            builder: (context, state) => TripDetailScreen(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/alerts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlertsScreen(),
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/subscriptions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SubscriptionsScreen(),
            ),
          ),
          GoRoute(
            path: '/support',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SupportDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/support/:id',
            pageBuilder: (context, state) => NoTransitionPage(
              child: TicketDetailScreen(ticketNumber: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/audit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuditDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
