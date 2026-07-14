import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';
import '../providers/live_provider.dart';

class LiveAlertsFeed extends StatelessWidget {
  const LiveAlertsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, provider, child) {
        final alerts = provider.alerts;
        if (alerts.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AdminTheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AdminTheme.danger),
              const SizedBox(width: 16),
              const Text('LIVE ALERTS', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              const SizedBox(width: 16),
              Container(width: 1, height: 30, color: AdminTheme.border),
              const SizedBox(width: 16),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: alert['severity'] == 'critical' ? AdminTheme.danger : AdminTheme.warning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '[${alert['vehicle_plate']}] ${alert['type']} - ${alert['message']}',
                              style: const TextStyle(color: AdminTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 1, duration: 300.ms);
      },
    );
  }
}
