import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../models/alert_model.dart';
import '../providers/alerts_provider.dart';
import 'alert_detail_panel.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _searchCtrl = TextEditingController();
  bool _filtersExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    context.read<AlertsProvider>().stopRefresh();
    super.dispose();
  }

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'critical': return AdminTheme.danger;
      case 'high':     return Colors.orange;
      case 'medium':   return AdminTheme.warning;
      case 'low':      return AdminTheme.info;
      default:         return AdminTheme.textSecondary;
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'new':          return AdminTheme.danger;
      case 'acknowledged': return AdminTheme.warning;
      case 'in progress':  return AdminTheme.info;
      case 'resolved':     return AdminTheme.success;
      case 'dismissed':    return AdminTheme.textSecondary;
      default:             return AdminTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AdminTheme.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(provider),
              _buildStatCards(provider),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left sidebar: filters
                    _buildFilterSidebar(context, provider),
                    // Center: alert table
                    Expanded(child: _buildAlertTable(context, provider)),
                    // Right: detail panel
                    if (provider.selectedAlert != null || provider.isDetailLoading)
                      SizedBox(
                        width: 380,
                        child: const AlertDetailPanel(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(AlertsProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notification_important, color: AdminTheme.danger, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alerts & Incident Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              Text('${provider.totalAlerts} total alerts • Auto-refreshes every 30s',
                  style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
            ],
          ),
          const Spacer(),
          // Search
          SizedBox(
            width: 280,
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search vehicle, org, driver, type...',
                hintStyle: const TextStyle(color: AdminTheme.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18, color: AdminTheme.textMuted),
                isDense: true,
                filled: true,
                fillColor: AdminTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AdminTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AdminTheme.border)),
              ),
              onChanged: (v) => provider.setSearch(v),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AdminTheme.textSecondary),
            onPressed: () {
              provider.fetchAlerts(refresh: true);
              provider.fetchStatistics();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(AlertsProvider provider) {
    final stats = provider.statistics;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        color: AdminTheme.surface,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        children: [
          _statCard('Critical Today', stats?.criticalToday.toString() ?? '—', AdminTheme.danger, Icons.warning_amber),
          _statCard('Fuel Theft', stats?.fuelTheftToday.toString() ?? '—', Colors.orange, Icons.local_gas_station),
          _statCard('Overspeed', stats?.overspeedToday.toString() ?? '—', AdminTheme.warning, Icons.speed),
          _statCard('Pending', stats?.pendingAlerts.toString() ?? '—', AdminTheme.info, Icons.pending_actions),
          _statCard('Resolved Today', stats?.resolvedToday.toString() ?? '—', AdminTheme.success, Icons.check_circle),
          _statCard('Avg Resolution',
              stats?.avgResolutionMinutes != null ? '${stats!.avgResolutionMinutes.toStringAsFixed(0)}m' : '—',
              AdminTheme.primary, Icons.timer),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSidebar(BuildContext context, AlertsProvider provider) {
    const List<String> types = [
      'All',
      'Fuel Theft',
      'Fuel Refill',
      'Overspeed',
      'Excessive Idling',
      'Harsh Braking',
      'Rapid Acceleration',
      'Sharp Cornering',
      'Engine Fault',
      'Device Offline',
      'GPS Signal Lost',
      'Low Device Battery',
      'High Device Temperature',
      'Vehicle Offline',
      'Trip Deviation',
      'Geofence Violation',
      'Insurance Expiry',
      'RC Expiry',
      'Fitness Expiry',
      'Pollution Certificate Expiry',
      'Driver License Expiry',
      'Organization Approval Pending',
      'Subscription Expiry',
    ];
    final List<String> orgs = ['All', ...provider.filterOptions['organizations'] ?? []];
    const severities = ['All', 'Critical', 'High', 'Medium', 'Low', 'Information'];
    const statuses = ['All', 'New', 'Acknowledged', 'In Progress', 'Resolved', 'Dismissed'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _filtersExpanded ? 220 : 48,
      decoration: const BoxDecoration(
        color: AdminTheme.surface,
        border: Border(right: BorderSide(color: AdminTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapse toggle
          InkWell(
            onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(_filtersExpanded ? Icons.filter_list_off : Icons.filter_list,
                      color: AdminTheme.primary, size: 20),
                  if (_filtersExpanded) ...[
                    const SizedBox(width: 8),
                    const Text('Filters', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: provider.clearFilters,
                      child: const Text('Clear', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_filtersExpanded) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterDropdown('Severity', provider.severityFilter, severities, provider.setSeverityFilter),
                    _filterDropdown('Status', provider.statusFilter, statuses, provider.setStatusFilter),
                    _filterDropdown('Alert Type', provider.typeFilter, types, provider.setTypeFilter),
                    _filterDropdown('Organization', provider.orgFilter, orgs, provider.setOrgFilter),
                    const SizedBox(height: 12),
                    const Text('Date Range', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _datePicker('From', provider.fromDate, (d) => provider.setDateRange(d, provider.toDate)),
                    const SizedBox(height: 6),
                    _datePicker('To', provider.toDate, (d) => provider.setDateRange(provider.fromDate, d)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterDropdown(String label, String current, List<String> options, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: options.contains(current) ? current : 'All',
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: AdminTheme.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AdminTheme.border)),
            ),
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ],
      ),
    );
  }

  Widget _datePicker(String label, String? current, Function(String?) onPick) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: current != null ? DateTime.tryParse(current) ?? DateTime.now() : DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AdminTheme.primary)), child: child!),
        );
        if (picked != null) onPick('${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AdminTheme.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 13, color: AdminTheme.textSecondary),
            const SizedBox(width: 6),
            Text(current ?? label, style: TextStyle(fontSize: 12, color: current != null ? AdminTheme.textPrimary : AdminTheme.textMuted)),
            if (current != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onPick(null),
                child: const Icon(Icons.close, size: 13, color: AdminTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTable(BuildContext ctx, AlertsProvider provider) {
    if (provider.isLoading && provider.alerts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AdminTheme.danger, size: 48),
            const SizedBox(height: 16),
            Text(provider.error!, style: const TextStyle(color: AdminTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => provider.fetchAlerts(refresh: true), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (provider.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: AdminTheme.textMuted),
            const SizedBox(height: 16),
            const Text('No alerts found', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Try adjusting your filters', style: TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Column headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AdminTheme.surface,
          child: Row(
            children: [
              _colHead('ID', 60),
              _colHead('Type', 160),
              _colHead('Severity', 90),
              _colHead('Status', 110),
              _colHead('Vehicle', 110),
              _colHead('Organization', 160),
              _colHead('Driver', 120),
              _colHead('Detected', 140),
              _colHead('Actions', 80),
            ],
          ),
        ),
        const Divider(height: 1, color: AdminTheme.border),
        // Alert rows
        Expanded(
          child: ListView.builder(
            itemCount: provider.alerts.length + 1,
            itemBuilder: (ctx, i) {
              if (i == provider.alerts.length) {
                if (provider.alerts.length < provider.totalAlerts) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.expand_more),
                        label: Text('Load More (${provider.totalAlerts - provider.alerts.length} remaining)'),
                        onPressed: provider.loadNextPage,
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 16);
              }
              return _alertRow(ctx, provider, provider.alerts[i]);
            },
          ),
        ),
        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AdminTheme.border)),
            color: AdminTheme.surface,
          ),
          child: Row(
            children: [
              Text('Showing ${provider.alerts.length} of ${provider.totalAlerts} alerts',
                  style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
              if (provider.isLoading) ...[
                const SizedBox(width: 12),
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _alertRow(BuildContext ctx, AlertsProvider provider, AlertModel alert) {
    final isSelected = provider.selectedAlert?.id == alert.id;

    return InkWell(
      onTap: () => provider.selectAlert(alert.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primary.withOpacity(0.08) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AdminTheme.primary : _severityColor(alert.severity),
              width: 3,
            ),
            bottom: const BorderSide(color: AdminTheme.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 60, child: Text('#${alert.id}', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12))),
            SizedBox(
              width: 160,
              child: Row(
                children: [
                  Icon(_alertTypeIcon(alert.type), size: 14, color: _severityColor(alert.severity)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(alert.type, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: _badge(alert.severity, _severityColor(alert.severity)),
            ),
            SizedBox(
              width: 110,
              child: _badge(alert.status, _statusColor(alert.status)),
            ),
            SizedBox(width: 110, child: Text(alert.vehiclePlate ?? '—', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 160, child: Text(alert.organizationName ?? '—', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 120, child: Text(alert.driver ?? '—', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 140, child: Text(_fmtDate(alert.detectedAt), style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11))),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  if (alert.status.toLowerCase() == 'new')
                    IconButton(
                      tooltip: 'Acknowledge',
                      icon: const Icon(Icons.check_circle_outline, size: 16, color: AdminTheme.warning),
                      onPressed: () => provider.updateStatus(alert.id, 'Acknowledged'),
                    ),
                  IconButton(
                    tooltip: 'View Details',
                    icon: const Icon(Icons.open_in_new, size: 16, color: AdminTheme.textSecondary),
                    onPressed: () => provider.selectAlert(alert.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colHead(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
    );
  }

  IconData _alertTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fuel theft':           return Icons.local_gas_station;
      case 'overspeed':            return Icons.speed;
      case 'excessive idling':     return Icons.timer;
      case 'harsh braking':        return Icons.front_hand;
      case 'device offline':       return Icons.signal_wifi_off;
      case 'gps signal lost':      return Icons.gps_off;
      case 'engine fault':         return Icons.build;
      case 'vehicle offline':      return Icons.directions_car;
      case 'insurance expiry':
      case 'rc expiry':
      case 'fitness expiry':
      case 'driver license expiry': return Icons.assignment_late;
      default:                     return Icons.warning_amber;
    }
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}\n'
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
