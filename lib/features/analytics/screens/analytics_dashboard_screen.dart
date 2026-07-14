import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:universal_html/html.dart' as html;
import '../../../app/theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../../organizations/services/organizations_service.dart';
import '../../vehicles/services/vehicles_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _vehicleCtrl = TextEditingController();
  final TextEditingController _driverCtrl = TextEditingController();

  List<dynamic> _organizationsList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchAllAnalytics();
      _loadOrganizations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vehicleCtrl.dispose();
    _driverCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    try {
      final list = await OrganizationsService().getOrganizations();
      setState(() {
        _organizationsList = list;
      });
    } catch (_) {}
  }

  void _triggerExport(String format) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generating $format report, please wait...'), backgroundColor: AdminTheme.primary),
      );
      final bytes = await context.read<AnalyticsProvider>().exportAnalytics(format);
      if (bytes.isNotEmpty) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final fileExtension = format == 'excel' ? 'xls' : (format == 'pdf' ? 'html' : 'csv');
        html.AnchorElement(href: url)
          ..setAttribute('download', 'platform_analytics_report.$fileExtension')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AdminTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AdminTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.analytics, color: AdminTheme.primaryLight, size: 28),
            const SizedBox(width: 12),
            const Text('Platform Analytics Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AdminTheme.textSecondary),
            tooltip: 'Refresh Data',
            onPressed: provider.fetchAllAnalytics,
          ),
          const SizedBox(width: 8),
          _buildExportButton(),
          const SizedBox(width: 24),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(provider),
          _buildTabBar(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: LoadingWidget(message: 'Compiling platform metrics...'))
                : provider.error != null
                    ? Center(
                        child: EmptyState(
                          icon: Icons.error_outline,
                          title: 'Error loading analytics',
                          description: provider.error!,
                          actionLabel: 'Retry',
                          onAction: provider.fetchAllAnalytics,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(provider),
                          _buildFuelTab(provider),
                          _buildVehiclesTab(provider),
                          _buildDriversTab(provider),
                          _buildTripsTab(provider),
                          _buildDevicesTab(provider),
                          _buildOrganizationsTab(provider),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // ── Filter Bar ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar(AnalyticsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AdminTheme.surface,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Organization Dropdown
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: (provider.selectedOrgId == null || _organizationsList.any((o) => o['uid'] == provider.selectedOrgId)) ? provider.selectedOrgId : null,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Organization',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  dropdownColor: AdminTheme.card,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Organizations', style: TextStyle(color: AdminTheme.textSecondary)),
                    ),
                    ..._organizationsList.map((org) {
                      return DropdownMenuItem<String>(
                        value: org['uid'],
                        child: Text(org['company_name'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary)),
                      );
                    }),
                  ],
                  onChanged: (val) => provider.setOrganization(val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    try {
                      final vehiclesData = await VehiclesService().getAllVehicles(search: textEditingValue.text, limit: 10);
                      final List<dynamic> vehicles = vehiclesData['vehicles'] ?? [];
                      return vehicles.map((v) => v.plate.toString());
                    } catch (_) {
                      return const Iterable<String>.empty();
                    }
                  },
                  onSelected: (String selection) {
                    _vehicleCtrl.text = selection;
                    provider.setVehicle(selection);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Plate',
                        hintText: 'Type to search...',
                        suffixIcon: controller.text.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search, color: AdminTheme.primary),
                                    tooltip: 'Search',
                                    onPressed: () {
                                      onEditingComplete();
                                      provider.setVehicle(controller.text.trim());
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    tooltip: 'Clear',
                                    onPressed: () {
                                      controller.clear();
                                      setState(() {});
                                      provider.setVehicle(null);
                                    },
                                  ),
                                ],
                              )
                            : const Icon(Icons.directions_car),
                      ),
                      onChanged: (val) => setState(() {}),
                      onSubmitted: (val) {
                        onEditingComplete();
                        provider.setVehicle(val.isEmpty ? null : val.trim());
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Driver Search
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _driverCtrl,
                  decoration: InputDecoration(
                    labelText: 'Driver Name',
                    hintText: 'Type name (partial ok)',
                    suffixIcon: _driverCtrl.text.isNotEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search, color: AdminTheme.primary),
                                tooltip: 'Search',
                                onPressed: () => provider.setDriver(_driverCtrl.text.trim()),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                tooltip: 'Clear',
                                onPressed: () {
                                  _driverCtrl.clear();
                                  setState(() {});
                                  provider.setDriver(null);
                                },
                              ),
                            ],
                          )
                        : const Icon(Icons.person),
                  ),
                  onChanged: (val) => setState(() {}),
                  onSubmitted: (val) => provider.setDriver(val.isEmpty ? null : val.trim()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Period Choice Chips
              Row(
                children: ['Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom'].map((period) {
                  final isSelected = provider.selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      selectedColor: AdminTheme.primary.withOpacity(0.2),
                      backgroundColor: AdminTheme.card,
                      labelStyle: TextStyle(
                        color: isSelected ? AdminTheme.primaryLight : AdminTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isSelected ? AdminTheme.primary : AdminTheme.border),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          if (period == 'Custom') {
                            _selectCustomDateRange(context, provider);
                          } else {
                            provider.setPeriod(period);
                          }
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              // Reset Button
              TextButton.icon(
                icon: const Icon(Icons.filter_list_off, size: 18),
                label: const Text('Reset All Filters'),
                onPressed: () {
                  _vehicleCtrl.clear();
                  _driverCtrl.clear();
                  provider.resetFilters();
                },
                style: TextButton.styleFrom(foregroundColor: AdminTheme.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context, AnalyticsProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: provider.customDateRange ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
      firstDate: DateTime(2025),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AdminTheme.primary,
              onPrimary: Colors.white,
              surface: AdminTheme.surface,
              onSurface: AdminTheme.textPrimary,
            ),
            dialogBackgroundColor: AdminTheme.card,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setCustomDateRange(picked);
    }
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: AdminTheme.surface,
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AdminTheme.primary,
        labelColor: AdminTheme.primaryLight,
        unselectedLabelColor: AdminTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.dashboard_customize_outlined, size: 18)),
          Tab(text: 'Fuel Analytics', icon: Icon(Icons.local_gas_station_outlined, size: 18)),
          Tab(text: 'Vehicle Performance', icon: Icon(Icons.local_shipping_outlined, size: 18)),
          Tab(text: 'Driver Behaviour', icon: Icon(Icons.people_outline, size: 18)),
          Tab(text: 'Trip Statistics', icon: Icon(Icons.alt_route_outlined, size: 18)),
          Tab(text: 'Device Status', icon: Icon(Icons.settings_input_antenna_outlined, size: 18)),
          Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard_outlined, size: 18)),
        ],
      ),
    );
  }

  // ── Export Menu Button ─────────────────────────────────────────────────────
  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.file_download_outlined, color: AdminTheme.textPrimary),
      tooltip: 'Export Reports',
      color: AdminTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AdminTheme.border)),
      onSelected: _triggerExport,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.description, color: AdminTheme.secondary, size: 18),
              SizedBox(width: 8),
              Text('Export as CSV', style: TextStyle(color: AdminTheme.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.table_view, color: AdminTheme.success, size: 18),
              SizedBox(width: 8),
              Text('Export as Excel (XLS)', style: TextStyle(color: AdminTheme.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AdminTheme.danger, size: 18),
              SizedBox(width: 8),
              Text('Print PDF Report', style: TextStyle(color: AdminTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────
  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: AdminTheme.card,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0.0);
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 24, color: AdminTheme.border),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ── Line Chart Helper ──────────────────────────────────────────────────────
  Widget _buildLineChart(List<dynamic> trendPoints, String label, Color lineCol) {
    if (trendPoints.isEmpty) {
      return const Center(child: Text('No trend data available', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    final List<FlSpot> spots = [];
    final Map<double, String> xLabels = {};
    for (int i = 0; i < trendPoints.length; i++) {
      final p = trendPoints[i];
      final val = (p['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
      
      final dateStr = (p['date'] ?? p['name'] ?? '').toString();
      if (dateStr.length >= 5) {
        xLabels[i.toDouble()] = dateStr.substring(dateStr.length - 5); // Keep MM-DD format
      }
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final text = xLabels[val] ?? '';
                if (val.toInt() % (spots.length > 7 ? spots.length ~/ 4 : 1) == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(text, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 10)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineCol,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineCol.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bar Chart Helper ───────────────────────────────────────────────────────
  Widget _buildBarChart(List<dynamic> dataItems, Color barCol) {
    if (dataItems.isEmpty) {
      return const Center(child: Text('No chart data available', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    final List<BarChartGroupData> groups = [];
    final Map<double, String> labels = {};

    for (int i = 0; i < dataItems.length; i++) {
      final item = dataItems[i];
      final val = (item['value'] as num).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val,
              color: barCol,
              width: 16,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        ),
      );
      labels[i.toDouble()] = (item['name'] ?? '').toString();
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final txt = labels[val] ?? '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    txt.length > 8 ? '${txt.substring(0, 7)}..' : txt,
                    style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }

  // ── Pie Chart Helper ───────────────────────────────────────────────────────
  Widget _buildPieChart(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No distribution data available', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    final List<Color> colors = [
      AdminTheme.primary,
      AdminTheme.secondary,
      AdminTheme.success,
      AdminTheme.warning,
      AdminTheme.danger,
      AdminTheme.info,
      Colors.purple,
      Colors.pink,
    ];

    double total = items.fold(0.0, (sum, item) => sum + (item['value'] as num).toDouble());

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(items.length, (i) {
                final item = items[i];
                final val = (item['value'] as num).toDouble();
                final pct = total > 0 ? (val / total * 100).toStringAsFixed(1) : '0';
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: val,
                  title: '$pct%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: List.generate(items.length, (i) {
                final item = items[i];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${item['name'] ?? 'N/A'} (${item['value']})', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ── TAB: Overview ──────────────────────────────────────────────────────────
  Widget _buildOverviewTab(AnalyticsProvider provider) {
    final d = provider.overviewData;
    if (d == null) {
      return const Center(child: Text('No data for selected filters', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard('Total Organizations', d['totalOrganizations'].toString(), Icons.domain, AdminTheme.primary),
              _buildKpiCard('Fleet Owners', d['totalFleetOwners'].toString(), Icons.people_alt, AdminTheme.secondary),
              _buildKpiCard('Vehicles Enrolled', d['totalVehicles'].toString(), Icons.local_shipping, AdminTheme.success),
              _buildKpiCard('Assigned Drivers', d['totalDrivers'].toString(), Icons.badge, AdminTheme.info),
              _buildKpiCard('IoT Devices', d['totalDevices'].toString(), Icons.router, AdminTheme.primaryLight),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard('Active Trips Today', d['activeTripsToday'].toString(), Icons.play_arrow, AdminTheme.success),
              _buildKpiCard('Vehicles Online', d['onlineVehicles'].toString(), Icons.check_circle_outline, AdminTheme.secondary),
              _buildKpiCard('Vehicles Offline', d['offlineVehicles'].toString(), Icons.remove_circle_outline, AdminTheme.danger),
              _buildKpiCard('Critical Alerts Today', d['criticalAlertsToday'].toString(), Icons.warning, AdminTheme.danger),
              _buildKpiCard('Fuel Theft Events', d['fuelTheftIncidents'].toString(), Icons.local_gas_station, AdminTheme.warning),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 350,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSectionCard(
                    title: 'Active Trips vs Critical Alerts Activity (Last 30 Days)',
                    child: provider.tripData != null
                        ? _buildLineChart(provider.tripData!['tripsTrend'] ?? [], 'Trips Count', AdminTheme.primary)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildSectionCard(
                    title: 'System Incidents Breakdown',
                    child: provider.alertData != null
                        ? _buildPieChart(provider.alertData!['alertsByType'] ?? [])
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ── TAB: Fuel ──────────────────────────────────────────────────────────────
  Widget _buildFuelTab(AnalyticsProvider provider) {
    final d = provider.fuelData;
    if (d == null) {
      return const Center(child: Text('No fuel data for selected filters', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard('Total Fuel Consumed', '${d['totalFuelConsumed'].toStringAsFixed(1)} L', Icons.local_gas_station, AdminTheme.primary),
              _buildKpiCard('Average Fuel Consumed', '${d['avgFuelConsumption'].toStringAsFixed(1)} L', Icons.bar_chart, AdminTheme.info),
              _buildKpiCard('Fuel Saved', '${d['fuelSaved'].toStringAsFixed(1)} L', Icons.eco, AdminTheme.success),
              _buildKpiCard('Idling Waste (Est)', '${d['estimatedFuelWastedIdling'].toStringAsFixed(1)} L', Icons.timer_outlined, AdminTheme.danger),
              _buildKpiCard('Theft Loss Volume', '${d['fuelTheftVolume'].toStringAsFixed(1)} L', Icons.security, AdminTheme.warning),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320,
            child: Row(
              children: [
                Expanded(
                  child: _buildSectionCard(
                    title: 'Fuel Consumption Trend',
                    child: _buildLineChart(d['fuelConsumptionTrend'] ?? [], 'Consumed (L)', AdminTheme.secondary),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildSectionCard(
                    title: 'Top 5 Fuel Efficient Organizations (Avg Mileage km/L)',
                    child: _buildBarChart(d['topFuelEfficientOrgs'] ?? [], AdminTheme.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB: Vehicles ──────────────────────────────────────────────────────────
  Widget _buildVehiclesTab(AnalyticsProvider provider) {
    final d = provider.vehicleData;
    if (d == null) {
      return const Center(child: Text('No vehicle data for selected filters', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildKpiCard('Distance Travelled', '${d['totalDistanceTravelled'].toStringAsFixed(1)} km', Icons.map, AdminTheme.primary),
              _buildKpiCard('Avg Distance Per Vehicle', '${d['avgDistancePerVehicle'].toStringAsFixed(1)} km', Icons.timeline, AdminTheme.info),
              _buildKpiCard('Utilization Rate', '${d['vehicleUtilization'].toStringAsFixed(1)}%', Icons.pie_chart, AdminTheme.success),
              _buildKpiCard('Under Maintenance', d['vehiclesUnderMaintenance'].toString(), Icons.build, AdminTheme.warning),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: AdminTheme.card,
                  child: ListTile(
                    leading: const Icon(Icons.star, color: AdminTheme.success, size: 36),
                    title: const Text('Most Active Vehicle', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                    subtitle: Text(d['mostActiveVehicle'] != null ? '${d['mostActiveVehicle']['plate']} (${d['mostActiveVehicle']['value'].toStringAsFixed(1)} km)' : 'None', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Card(
                  color: AdminTheme.card,
                  child: ListTile(
                    leading: const Icon(Icons.star_half, color: AdminTheme.warning, size: 36),
                    title: const Text('Least Active Vehicle', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                    subtitle: Text(d['leastActiveVehicle'] != null ? '${d['leastActiveVehicle']['plate']} (${d['leastActiveVehicle']['value'].toStringAsFixed(1)} km)' : 'None', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB: Drivers ───────────────────────────────────────────────────────────
  Widget _buildDriversTab(AnalyticsProvider provider) {
    final d = provider.driverData;
    if (d == null) {
      return const Center(child: Text('No driver data for selected filters', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard('Total Active Drivers', d['totalActiveDrivers'].toString(), Icons.people_outline, AdminTheme.primary),
              _buildKpiCard('Driver Utilization', '${d['driverUtilization'].toStringAsFixed(1)}%', Icons.donut_large, AdminTheme.success),
              _buildKpiCard('Overspeed Events', d['overspeedEvents'].toString(), Icons.speed, AdminTheme.warning),
              _buildKpiCard('Harsh Braking Events', d['harshBrakingEvents'].toString(), Icons.stop_screen_share, AdminTheme.danger),
              _buildKpiCard('Rapid Acceleration', d['rapidAccelerationEvents'].toString(), Icons.north_east, AdminTheme.info),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionCard(
            title: 'Top Driver Safety Ranking',
            child: d['driverSafetyRanking'] != null && (d['driverSafetyRanking'] as List).isNotEmpty
                ? Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border))),
                        children: [
                          Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('DRIVER NAME', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                          Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('ORGANIZATION', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                          Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('SAFETY SCORE', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                          Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('RATING', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                        ],
                      ),
                      ...(d['driverSafetyRanking'] as List).map((row) {
                        return TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text(row['name'] ?? '', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text(row['organization'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textSecondary))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text(row['score'].toString(), style: TextStyle(color: row['score'] >= 80 ? AdminTheme.success : AdminTheme.warning, fontWeight: FontWeight.bold))),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(row['rating'].toStringAsFixed(1), style: const TextStyle(color: AdminTheme.textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  )
                : const Center(child: Text('No driver safety data available', style: TextStyle(color: AdminTheme.textSecondary))),
          ),
        ],
      ),
    );
  }

  // ── TAB: Trips ─────────────────────────────────────────────────────────────
  Widget _buildTripsTab(AnalyticsProvider provider) {
    final d = provider.tripData;
    if (d == null) {
      return const Center(child: Text('No trip data for selected filters', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard('Trips Today', d['tripsToday'].toString(), Icons.today, AdminTheme.primary),
              _buildKpiCard('Trips This Week', d['tripsThisWeek'].toString(), Icons.date_range, AdminTheme.info),
              _buildKpiCard('Trips This Month', d['tripsThisMonth'].toString(), Icons.calendar_month, AdminTheme.success),
              _buildKpiCard('Completed Trips', d['completedTrips'].toString(), Icons.task_alt, AdminTheme.success),
              _buildKpiCard('Cancelled Trips', d['cancelledTrips'].toString(), Icons.cancel_outlined, AdminTheme.danger),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSectionCard(
                    title: 'Trips Activity Volume Trend',
                    child: _buildLineChart(d['tripsTrend'] ?? [], 'Trips Run', AdminTheme.info),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildSectionCard(
                    title: 'Completions vs Cancellations',
                    child: _buildPieChart([
                      { 'name': 'Completed', 'value': d['completedTrips'] },
                      { 'name': 'Cancelled', 'value': d['cancelledTrips'] }
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB: Devices ───────────────────────────────────────────────────────────
  Widget _buildDevicesTab(AnalyticsProvider provider) {
    final d = provider.deviceData;
    if (d == null) {
      return const Center(child: Text('No device data for selected filters', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildKpiCard('Online Devices', d['onlineDevices'].toString(), Icons.wifi, AdminTheme.success),
              _buildKpiCard('Offline Devices', d['offlineDevices'].toString(), Icons.wifi_off, AdminTheme.danger),
              _buildKpiCard('Avg Signal Strength', '${d['averageSignalStrength'].toStringAsFixed(1)}%', Icons.signal_cellular_alt, AdminTheme.info),
              _buildKpiCard('GPS Fix Availability', '${d['gpsAvailability'].toStringAsFixed(1)}%', Icons.gps_fixed, AdminTheme.success),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320,
            child: Row(
              children: [
                Expanded(
                  child: _buildSectionCard(
                    title: 'Firmware Version Distribution',
                    child: _buildPieChart(d['firmwareDistribution'] ?? []),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildSectionCard(
                    title: 'Hardware Model Distribution',
                    child: _buildPieChart(d['hardwareVersionDistribution'] ?? []),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // ── TAB: Leaderboard ───────────────────────────────────────────────────────
  Widget _buildOrganizationsTab(AnalyticsProvider provider) {
    return FutureBuilder<List<dynamic>>(
      future: OrganizationsService().getOrganizations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading organizations rankings: ${snapshot.error}', style: const TextStyle(color: AdminTheme.danger)));
        }

        final orgs = snapshot.data ?? [];
        if (orgs.isEmpty) {
          return const Center(child: Text('No organizations registered', style: TextStyle(color: AdminTheme.textSecondary)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'DravYantra Platform Leaderboard & Operational Index',
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(1.5),
                    5: FlexColumnWidth(1.5),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border))),
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('ORGANIZATION', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('CITY', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('STATE', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('VEHICLES ENROLLED', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('DRIVERS ASSIGNED', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('ONBOARDING STATUS', style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryLight, fontSize: 12))),
                      ],
                    ),
                    ...orgs.map((org) {
                      final status = (org['status'] ?? 'Pending').toString();
                      Color statusCol = AdminTheme.textSecondary;
                      if (status == 'Approved') statusCol = AdminTheme.success;
                      if (status == 'Suspended') statusCol = AdminTheme.warning;
                      if (status == 'Rejected') statusCol = AdminTheme.danger;

                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              org['company_name'] ?? 'N/A',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                            ),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 14.0), child: Text(org['city'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textSecondary))),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 14.0), child: Text(org['state'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textSecondary))),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              (org['vehicle_count'] ?? '0').toString(),
                              style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              (org['driver_count'] ?? '0').toString(),
                              style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusCol.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(status.toUpperCase(), style: TextStyle(color: statusCol, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
