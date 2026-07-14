import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../providers/live_provider.dart';
import 'live_map_view.dart';
import 'live_vehicle_panel.dart';
import 'live_alerts_feed.dart';

class LiveFleetScreen extends StatefulWidget {
  const LiveFleetScreen({super.key});

  @override
  State<LiveFleetScreen> createState() => _LiveFleetScreenState();
}

class _LiveFleetScreenState extends State<LiveFleetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    // Note: Provider dispose will handle stopping the timer if provided properly,
    // but we can also manually call stopPolling when this screen is unmounted.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AdminTheme.background,
      body: Row(
        children: [
          // Main map and top overlay area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                LiveMapView(),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _LiveTopBar(),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: LiveAlertsFeed(),
                ),
              ],
            ),
          ),
          
          // Side panel for details and filters
          SizedBox(
            width: 400,
            child: LiveVehiclePanel(),
          ),
        ],
      ),
    );
  }
}

class _LiveTopBar extends StatelessWidget {
  const _LiveTopBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, provider, child) {
        final stats = provider.dashboardStats;
        if (stats == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AdminTheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: 'Online', value: stats['onlineVehicles'].toString(), color: AdminTheme.success),
              _StatItem(label: 'Moving', value: stats['vehiclesMoving'].toString(), color: AdminTheme.primary),
              _StatItem(label: 'Idle', value: stats['vehiclesIdle'].toString(), color: AdminTheme.warning),
              _StatItem(label: 'Parked', value: stats['vehiclesParked'].toString(), color: AdminTheme.info),
              _StatItem(label: 'Offline', value: stats['offlineVehicles'].toString(), color: AdminTheme.textSecondary),
              Container(width: 1, height: 30, color: AdminTheme.border),
              _StatItem(label: 'Critical Alerts', value: stats['criticalAlerts'].toString(), color: AdminTheme.danger),
              _StatItem(label: 'Fuel Theft', value: stats['fuelTheftAlerts'].toString(), color: AdminTheme.danger),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary)),
      ],
    );
  }
}
