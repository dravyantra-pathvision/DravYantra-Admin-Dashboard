import 'package:flutter/material.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/recent_table.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../app/theme.dart';
import '../models/dashboard_models.dart';
import '../services/admin_dashboard_service.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = AdminDashboardService();
      final data = await service.fetchDashboardSummary();
      
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget(message: 'Loading dashboard...'));
    }

    if (_errorMessage != null) {
      return Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Failed to Load Dashboard',
          description: _errorMessage!,
          actionLabel: 'Retry',
          onAction: _fetchDashboardData,
        ),
      );
    }

    if (_dashboardData == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 32),
          _buildStatGrid(context),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1200) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildOrganizationsTable(),
                          const SizedBox(height: 32),
                          _buildFleetOwnersTable(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildRecentAlerts(),
                          const SizedBox(height: 32),
                          _buildSystemHealth(),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrganizationsTable(),
                    const SizedBox(height: 32),
                    _buildFleetOwnersTable(),
                    const SizedBox(height: 32),
                    _buildRecentAlerts(),
                    const SizedBox(height: 32),
                    _buildSystemHealth(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AdminTheme.sidebarGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is what is happening with the DravYantra system today.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (screenWidth < 600) {
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
    } else if (screenWidth < 1200) {
      crossAxisCount = 3;
    }

    final stats = _dashboardData!['statistics'];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        StatCard(title: 'Total Organizations', value: '${stats['totalOrganizations']}', icon: Icons.business, trendValue: 'Live', isTrendUp: true),
        StatCard(title: 'Fleet Owners', value: '${stats['totalFleetOwners']}', icon: Icons.groups, trendValue: 'Live', isTrendUp: true),
        StatCard(title: 'Active Vehicles', value: '${stats['totalVehicles']}', icon: Icons.directions_car, trendValue: 'Live', isTrendUp: true),
        StatCard(title: 'Active Drivers', value: '${stats['totalDrivers']}', icon: Icons.person_pin, trendValue: 'Live', isTrendUp: true),
        StatCard(title: 'Online Devices', value: '${stats['onlineDevices']}', icon: Icons.devices, trendValue: 'Live', isTrendUp: true, iconColor: AdminTheme.success),
        StatCard(title: 'Active Trips', value: '${stats['activeTrips']}', icon: Icons.route, trendValue: 'Live', isTrendUp: true),
        StatCard(title: 'Critical Alerts', value: '${stats['criticalAlerts']}', icon: Icons.warning, trendValue: 'Live', isTrendUp: false, iconColor: AdminTheme.danger),
        StatCard(title: 'Active Subscriptions', value: '${stats['activeSubscriptions']}', icon: Icons.card_membership, trendValue: 'Live', isTrendUp: true),
      ],
    );
  }

  Widget _buildOrganizationsTable() {
    final items = _dashboardData!['recentOrganizations'] as List<DashboardOrganization>;
    return RecentTable<DashboardOrganization>(
      title: 'Recent Organizations',
      columns: const ['Name', 'Admin Email', 'Vehicles', 'Status'],
      items: items,
      onViewAll: () => context.go('/organizations'),
      rowBuilder: (org) => [
        Text(org.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(org.adminEmail),
        Text(org.vehicleCount.toString()),
        _buildStatusBadge(org.status),
      ],
    );
  }

  Widget _buildFleetOwnersTable() {
    final items = _dashboardData!['recentFleetOwners'] as List<DashboardFleetOwner>;
    return RecentTable<DashboardFleetOwner>(
      title: 'Recent Fleet Owners',
      columns: const ['Name', 'Email', 'Organization', 'Joined Date', 'Status'],
      items: items,
      onViewAll: () => context.go('/fleet-owners'),
      rowBuilder: (owner) => [
        Text(owner.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(owner.email),
        Text(owner.organization),
        Text(owner.joinedDate),
        _buildStatusBadge(owner.status),
      ],
    );
  }

  Widget _buildRecentAlerts() {
    final items = _dashboardData!['recentAlerts'] as List<DashboardAlert>;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
                TextButton(onPressed: () => context.go('/alerts'), child: const Text('View All')),
              ],
            ),
          ),
          if (items.isEmpty)
             const Padding(
               padding: EdgeInsets.all(20),
               child: Text('No recent alerts', style: TextStyle(color: AdminTheme.textMuted)),
             )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AdminTheme.border),
              itemBuilder: (context, index) {
                final alert = items[index];
                final isCritical = alert.severity.toLowerCase() == 'critical';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isCritical ? AdminTheme.danger : AdminTheme.warning).withOpacity(0.1),
                    child: Icon(
                      isCritical ? Icons.error_outline : Icons.warning_amber,
                      color: isCritical ? AdminTheme.danger : AdminTheme.warning,
                    ),
                  ),
                  title: Text(alert.message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text('${alert.vehicleId} • ${alert.time}', style: const TextStyle(fontSize: 12)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
          const SizedBox(height: 24),
          _buildHealthRow('API Server', 'Operational', AdminTheme.success),
          const SizedBox(height: 16),
          _buildHealthRow('Database', 'Operational', AdminTheme.success),
          const SizedBox(height: 16),
          _buildHealthRow('Redis Cache', 'Degraded', AdminTheme.warning),
          const SizedBox(height: 16),
          _buildHealthRow('Device Gateway', 'Operational', AdminTheme.success),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String service, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(service, style: const TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AdminTheme.success : AdminTheme.textMuted).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? AdminTheme.success : AdminTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
