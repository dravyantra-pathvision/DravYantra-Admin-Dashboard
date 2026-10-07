import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app/theme.dart';
import 'app/theme_provider.dart';
import 'app/router.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/vehicles/providers/vehicles_provider.dart';
import 'features/drivers/providers/drivers_provider.dart';
import 'features/trips/providers/trips_provider.dart';
import 'features/live/providers/live_provider.dart';
import 'features/alerts/providers/alerts_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/reports/providers/reports_provider.dart';
import 'features/settings/settings_provider.dart';
import 'features/support/providers/support_provider.dart';
import 'features/subscriptions/providers/subscriptions_provider.dart';
import 'features/audit/providers/audit_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/recycle_bin/providers/recycle_bin_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (might need options): $e');
  }

  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => VehiclesProvider()),
        ChangeNotifierProvider(create: (_) => DriversProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => LiveProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionsProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => RecycleBinProvider()),
      ],
      child: AdminApp(authProvider: authProvider),
    ),
  );
}

class AdminApp extends StatefulWidget {
  final AuthProvider authProvider;
  const AdminApp({super.key, required this.authProvider});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final _router = createRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: 'DravYantra Admin',
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
