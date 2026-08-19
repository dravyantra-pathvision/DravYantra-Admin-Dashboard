import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../settings_provider.dart';
import '../models/system_settings_model.dart';
import '../../../app/theme.dart';

import '../../recycle_bin/providers/recycle_bin_provider.dart';
import '../../recycle_bin/models/recycled_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCategory = 'general';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Clean metadata dictionary for essential DravYantra settings (Zero bloat)
  final Map<String, Map<String, dynamic>> _settingMeta = {
    // 1. General & Platform Identity (general)
    'platform_name': {
      'name': 'Platform Brand Name',
      'desc': 'Primary title displayed across mobile apps, admin portal, and emails',
      'icon': Icons.business_rounded,
      'unit': '',
    },
    'support_email': {
      'name': 'Customer Support Email',
      'desc': 'Official helpdesk support email address rendered in mobile app help centers',
      'icon': Icons.mark_email_read_rounded,
      'unit': '',
    },
    'default_timezone': {
      'name': 'Default System Timezone',
      'desc': 'Timezone used for calculating trip timelines and report dates',
      'icon': Icons.schedule_rounded,
      'unit': '',
    },
    'default_currency': {
      'name': 'Default Billing Currency',
      'desc': 'Base currency symbol for fuel cost calculations & subscription billing',
      'icon': Icons.currency_rupee_rounded,
      'unit': '',
    },

    // 2. Fleet & Safety Thresholds (thresholds)
    'overspeed_threshold_kmh': {
      'name': 'Global Speed Limit Ceiling',
      'desc': 'Speed ceiling in km/h triggering real-time over-speed violation alerts',
      'icon': Icons.speed_rounded,
      'unit': 'km/h',
    },
    'offline_device_timeout_min': {
      'name': 'Device Disconnect Timeout',
      'desc': 'Inactivity duration in minutes before marking vehicle device offline',
      'icon': Icons.wifi_off_rounded,
      'unit': 'mins',
    },
    'auto_close_trip_min': {
      'name': 'Automatic Trip End Timeout',
      'desc': 'Stationary vehicle duration in minutes after which an ongoing trip auto-ends',
      'icon': Icons.auto_delete_rounded,
      'unit': 'mins',
    },

    // 3. Fuel & Cost Management (fuel)
    'fuel_theft_threshold_pct': {
      'name': 'Fuel Theft Drop Sensitivity',
      'desc': 'Sudden fuel tank level drop percentage that flags a potential theft incident',
      'icon': Icons.local_gas_station_rounded,
      'unit': '%',
    },
    'idle_threshold_minutes': {
      'name': 'Idling Waste Alert Timeout',
      'desc': 'Duration of stationary engine operation to flag idle fuel waste',
      'icon': Icons.timer_off_rounded,
      'unit': 'mins',
    },
    'standard_fuel_price_per_liter': {
      'name': 'Benchmark Fuel Price (INR)',
      'desc': 'Default fuel cost per liter used for fleet financial calculations',
      'icon': Icons.payments_rounded,
      'unit': '₹/L',
    },

    // 4. Alerts & Integrations (alerts)
    'whatsapp_gateway_enabled': {
      'name': 'WhatsApp Alert Gateway',
      'desc': 'Enables real-time WhatsApp alert notifications dispatched to Fleet Owners',
      'icon': Icons.chat_rounded,
      'unit': '',
    },
    'map_provider': {
      'name': 'GIS Mapping Engine',
      'desc': 'Map tile provider for vehicle live tracking & route playback',
      'icon': Icons.map_rounded,
      'unit': '',
    },
    'cloud_storage_bucket': {
      'name': 'AWS S3 Storage Bucket',
      'desc': 'AWS S3 cloud bucket storing driver photos & vehicle documents',
      'icon': Icons.cloud_done_rounded,
      'unit': '',
    },
    'maintenance_mode': {
      'name': 'Platform Maintenance Mode',
      'desc': 'Restricts non-admin portal & mobile app logins during system upgrades',
      'icon': Icons.build_circle_rounded,
      'unit': '',
    },
  };

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'general',
      'label': 'General & Platform Identity',
      'icon': Icons.business_rounded,
      'desc': 'Platform name, support email, timezone & billing currency defaults',
    },
    {
      'key': 'thresholds',
      'label': 'Fleet & Safety Thresholds',
      'icon': Icons.speed_rounded,
      'desc': 'Global speed limit ceilings, device offline timeouts & trip end rules',
    },
    {
      'key': 'fuel',
      'label': 'Fuel & Cost Management',
      'icon': Icons.local_gas_station_rounded,
      'desc': 'Fuel theft sensitivity, idling waste limits & benchmark fuel prices',
    },
    {
      'key': 'alerts',
      'label': 'Alerts & Integrations',
      'icon': Icons.notifications_active_rounded,
      'desc': 'WhatsApp gateway toggle, GIS maps engine, AWS S3 bucket & maintenance switch',
    },
    {
      'key': 'recycle_bin',
      'label': 'Recycle Bin & Data Recovery',
      'icon': Icons.delete_sweep_rounded,
      'desc': 'Inspect deleted items, restore items to active screens, or permanently purge',
    },
  ];

  final ScrollController _recycleBinScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
      context.read<RecycleBinProvider>().fetchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recycleBinScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top System Status Banner
            _buildTopSystemNotice(),
            const SizedBox(height: 20),

            // Top Summary KPI Cards (Fleet Owner App Palette)
            _buildTopKpiSummary(provider),
            const SizedBox(height: 24),

            // Main Settings Layout: Left Category Navigation Sidebar + Right Content Panel
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Category Sidebar
                SizedBox(
                  width: 290,
                  child: _buildCategorySidebar(provider),
                ),
                const SizedBox(width: 24),

                // Right Column: Settings Options Cards
                Expanded(
                  child: _buildSettingsContentPanel(provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Operational Notice ─────────────────────────────────────────────────
  Widget _buildTopSystemNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AdminTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AdminTheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'DravYantra Settings Console: Operational parameters map live to PostgreSQL database and govern fleet telemetry, mobile apps & alert gateways.',
              style: TextStyle(color: AdminTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AdminTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('ADMIN CONSOLE ACTIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ── Top Summary KPI Cards ──────────────────────────────────────────────────
  Widget _buildTopKpiSummary(SettingsProvider provider) {
    int totalSettings = 0;
    provider.groupedSettings.forEach((_, list) => totalSettings += list.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildKpiCard('Platform Parameters', '$totalSettings Essential Settings', '4 Core Operational Domains', AdminTheme.primary, Icons.tune_rounded),
            _buildKpiCard('Cloud File Storage', 'AWS S3 Active', 'Bucket: dravyantra-uploads', AdminTheme.success, Icons.cloud_done_rounded),
            _buildKpiCard('Database Connection', 'AWS RDS PostgreSQL', 'Encrypted TLS 1.3', AdminTheme.info, Icons.storage_rounded),
            _buildKpiCard('Platform Status', '100% Operational', 'Zero Active Service Outages', AdminTheme.secondary, Icons.check_circle_rounded),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String mainValue, String subtitle, Color accentColor, IconData icon) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(mainValue, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AdminTheme.background,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Left Sidebar Category Navigation ───────────────────────────────────────
  Widget _buildCategorySidebar(SettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SETTINGS DOMAINS', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 16),
          ..._categories.map((cat) {
            final key = cat['key'] as String;
            final isSelected = _selectedCategory == key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedCategory = key);
                  if (key == 'recycle_bin') {
                    context.read<RecycleBinProvider>().fetchItems();
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AdminTheme.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AdminTheme.primary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat['icon'] as IconData, size: 20, color: isSelected ? AdminTheme.primary : AdminTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ── Right Settings Options Content Panel ───────────────────────────────────
  Widget _buildSettingsContentPanel(SettingsProvider provider) {
    if (_selectedCategory == 'recycle_bin') {
      return _buildRecycleBinView();
    }

    final catInfo = _categories.firstWhere((c) => c['key'] == _selectedCategory, orElse: () => _categories[0]);
    final List<SystemSetting> settingsList = provider.groupedSettings[_selectedCategory] ?? [];

    final filtered = settingsList.where((s) {
      if (_searchQuery.isEmpty) return true;
      final meta = _settingMeta[s.key];
      final neatName = meta?['name'] ?? s.key;
      return neatName.toLowerCase().contains(_searchQuery) ||
          s.key.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery) ||
          (s.value != null && s.value.toString().toLowerCase().contains(_searchQuery));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header Bar & Search Input
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(catInfo['icon'] as IconData, color: AdminTheme.primary, size: 22),
                        const SizedBox(width: 10),
                        Text(catInfo['label'] as String, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(catInfo['desc'] as String, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search settings...',
                    hintStyle: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AdminTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: AdminTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (provider.isLoading && provider.groupedSettings.isEmpty)
          const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        else if (filtered.isEmpty)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: AdminTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 40, color: AdminTheme.textMuted),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty ? 'No options match "$_searchQuery"' : 'No parameters in this category.',
                  style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final setting = filtered[index];
              return _buildSettingOptionCard(setting);
            },
          ),
      ],
    );
  }

  // ── Option Card Component ─────────────────────────────────────────────────
  Widget _buildSettingOptionCard(SystemSetting setting) {
    final meta = _settingMeta[setting.key];
    final String neatTitle = meta?['name'] ?? _formatKeyName(setting.key);
    final String neatDesc = meta?['desc'] ?? setting.description;
    final IconData icon = meta?['icon'] ?? Icons.tune_rounded;
    final String unit = meta?['unit'] ?? '';

    final bool isBoolValue = setting.value is bool || setting.value.toString().toLowerCase() == 'true' || setting.value.toString().toLowerCase() == 'false';
    final bool boolVal = setting.value is bool ? setting.value : setting.value.toString().toLowerCase() == 'true';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AdminTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),

          // Title & Subtitle & Display Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  neatTitle,
                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(neatDesc, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),

                if (!isBoolValue)
                  Row(
                    children: [
                      const Text('Setting Value: ', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AdminTheme.border),
                        ),
                        child: Text(
                          setting.isSensitive ? '••••••••••••' : '${_formatValueDisplay(setting.value)}${unit.isNotEmpty ? ' $unit' : ''}',
                          style: TextStyle(
                            color: setting.isSensitive ? AdminTheme.warning : AdminTheme.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Right Controls (Switch for Booleans / Edit & History for Text)
          if (isBoolValue)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: boolVal ? AdminTheme.success.withOpacity(0.12) : AdminTheme.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    boolVal ? 'ENABLED' : 'DISABLED',
                    style: TextStyle(color: boolVal ? AdminTheme.success : AdminTheme.danger, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: boolVal,
                  activeColor: AdminTheme.primary,
                  onChanged: (newVal) => _quickToggleBoolean(setting, newVal),
                ),
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AdminTheme.textSecondary, size: 18),
                  tooltip: 'Audit Logs',
                  onPressed: () => _showHistoryDialog(setting),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AdminTheme.textSecondary, size: 18),
                  tooltip: 'Audit History',
                  onPressed: () => _showHistoryDialog(setting),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                  label: const Text('Configure', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () => _showUpdateDialog(setting),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Boolean Switch Live Quick Toggle ───────────────────────────────────────
  Future<void> _quickToggleBoolean(SystemSetting setting, bool newVal) async {
    final meta = _settingMeta[setting.key];
    final neatTitle = meta?['name'] ?? _formatKeyName(setting.key);
    final provider = context.read<SettingsProvider>();

    final success = await provider.updateSetting(
      key: setting.key,
      value: newVal,
      category: setting.category,
      reason: 'Toggled via Admin Settings Panel to $newVal',
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $neatTitle is now ${newVal ? "ENABLED" : "DISABLED"}'),
          backgroundColor: AdminTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error updating $neatTitle: ${provider.error ?? "Failed to save"}'),
          backgroundColor: AdminTheme.danger,
        ),
      );
    }
  }

  // ── Formatted Update Parameter Modal ───────────────────────────────────────
  void _showUpdateDialog(SystemSetting setting) {
    final meta = _settingMeta[setting.key];
    final neatTitle = meta?['name'] ?? _formatKeyName(setting.key);
    final neatDesc = meta?['desc'] ?? setting.description;

    final TextEditingController valueController = TextEditingController(
      text: setting.value is String ? setting.value : jsonEncode(setting.value),
    );
    final TextEditingController reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AdminTheme.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AdminTheme.primary),
                  const SizedBox(width: 10),
                  Text('Configure $neatTitle', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(neatDesc, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valueController,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Setting Parameter Value',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                      maxLines: setting.isSensitive ? 1 : 2,
                      obscureText: setting.isSensitive,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Audit Reason (Required for security log)',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Please enter an audit reason.')),
                            );
                            return;
                          }

                          setStateDialog(() => isLoading = true);

                          dynamic finalValue;
                          try {
                            finalValue = jsonDecode(valueController.text);
                          } catch (e) {
                            finalValue = valueController.text;
                          }

                          final provider = Provider.of<SettingsProvider>(context, listen: false);
                          final success = await provider.updateSetting(
                            key: setting.key,
                            value: finalValue,
                            category: setting.category,
                            reason: reasonController.text,
                          );

                          setStateDialog(() => isLoading = false);

                          if (!mounted) return;

                          if (success) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Setting parameter updated successfully.')),
                            );
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('❌ Error: ${provider.error ?? "Failed to save"}')),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Parameter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Audit History Modal Timeline ──────────────────────────────────────────
  void _showHistoryDialog(SystemSetting setting) {
    final meta = _settingMeta[setting.key];
    final neatTitle = meta?['name'] ?? _formatKeyName(setting.key);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AdminTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 650,
            height: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, color: AdminTheme.primary),
                        const SizedBox(width: 10),
                        Text('Audit Timeline: $neatTitle', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AdminTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AdminTheme.border, height: 1),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<SettingHistory>>(
                    future: context.read<SettingsProvider>().getHistoryFor(setting.key),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading history: ${snapshot.error}', style: const TextStyle(color: AdminTheme.danger)));
                      }
                      final history = snapshot.data ?? [];
                      if (history.isEmpty) {
                        return const Center(
                          child: Text('No previous audit logs recorded for this parameter.', style: TextStyle(color: AdminTheme.textSecondary)),
                        );
                      }
                      return ListView.separated(
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final h = history[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AdminTheme.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AdminTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Updated Value: ${h.newValue}',
                                      style: const TextStyle(color: AdminTheme.success, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      h.changedAt != null ? DateFormat('MMM dd, yyyy HH:mm').format(h.changedAt!) : '—',
                                      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Modified by: ${h.changedByEmail ?? h.changedBy ?? "System Admin"}',
                                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12),
                                ),
                                if (h.changeReason != null && h.changeReason!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Audit Reason: "${h.changeReason}"',
                                    style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Formatting Helpers ────────────────────────────────────────────────────
  String _formatKeyName(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('.', ' ')
        .split(' ')
        .map((str) => str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1)}')
        .join(' ');
  }

  String _formatValueDisplay(dynamic val) {
    if (val == null) return 'Not Configured';
    if (val is Map || val is List) {
      return jsonEncode(val);
    }
    return val.toString();
  }

  // ── Recycle Bin View ────────────────────────────────────────────────────────
  Widget _buildRecycleBinView() {
    return Consumer<RecycleBinProvider>(
      builder: (context, binProvider, _) {
        final items = binProvider.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delete_sweep_rounded, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Recycle Bin & Data Recovery',
                          style: TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => binProvider.fetchItems(resetPage: true),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Items moved to Recycle Bin can be safely restored to their original screens or permanently deleted from the database.',
                    style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    onChanged: (val) => binProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search recycled items by name, email, or ID...',
                      prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: AdminTheme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeFilterPill(binProvider, 'all', 'All Items'),
                  _buildTypeFilterPill(binProvider, 'fleet_owner', 'Fleet Owners'),
                  _buildTypeFilterPill(binProvider, 'organization', 'Organizations'),
                  _buildTypeFilterPill(binProvider, 'vehicle', 'Vehicles'),
                  _buildTypeFilterPill(binProvider, 'driver', 'Drivers'),
                  _buildTypeFilterPill(binProvider, 'trip', 'Trips'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recycle Bin Table
            Container(
              decoration: BoxDecoration(
                color: AdminTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: binProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 48, color: AdminTheme.textSecondary),
                                SizedBox(height: 12),
                                Text('Recycle Bin is Empty', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('No deleted items found matching the selected category.', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Scrollbar(
                            controller: _recycleBinScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: SingleChildScrollView(
                              controller: _recycleBinScrollController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowMaxHeight: 64.0,
                                dataRowMinHeight: 52.0,
                                columnSpacing: 28.0,
                                showCheckboxColumn: false,
                                headingRowColor: WidgetStateProperty.all(AdminTheme.background),
                                columns: const [
                                  DataColumn(label: Text('ITEM NAME / ID', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('CATEGORY', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('DETAILS', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('DELETED DATE', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('ACTIONS', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                                ],
                                rows: items.map((item) {
                                  final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(item.deletedAt);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(item.title, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
                                      ),
                                      DataCell(_buildCategoryBadge(item.entityTypeLabel)),
                                      DataCell(
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.subtitle, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
                                            if (item.organization.isNotEmpty && item.organization != 'N/A')
                                              Text(item.organization, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(dateStr, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Restore Button
                                            ElevatedButton.icon(
                                              onPressed: () => _restoreRecycledItem(item),
                                              icon: const Icon(Icons.restore_from_trash_rounded, size: 16),
                                              label: const Text('Restore'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AdminTheme.success.withOpacity(0.15),
                                                foregroundColor: AdminTheme.success,
                                                elevation: 0,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Delete Permanently Button
                                            OutlinedButton.icon(
                                              onPressed: () => _hardDeleteRecycledItem(item),
                                              icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Colors.red),
                                              label: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeFilterPill(RecycleBinProvider provider, String key, String label) {
    final isSelected = provider.selectedType == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.setTypeFilter(key),
        selectedColor: AdminTheme.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AdminTheme.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        backgroundColor: AdminTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AdminTheme.primary : AdminTheme.border)),
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    Color bg = AdminTheme.primary.withOpacity(0.1);
    Color fg = AdminTheme.primary;
    if (label.contains('Fleet')) { bg = Colors.purple.withOpacity(0.1); fg = Colors.purple; }
    else if (label.contains('Org')) { bg = Colors.blue.withOpacity(0.1); fg = Colors.blue; }
    else if (label.contains('Vehicle')) { bg = Colors.teal.withOpacity(0.1); fg = Colors.teal; }
    else if (label.contains('Driver')) { bg = Colors.amber.withOpacity(0.15); fg = Colors.amber.shade900; }
    else if (label.contains('Trip')) { bg = Colors.indigo.withOpacity(0.1); fg = Colors.indigo; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _restoreRecycledItem(RecycledItem item) async {
    try {
      await context.read<RecycleBinProvider>().restoreItem(item.entityType, item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${item.entityTypeLabel} "${item.title}" restored successfully to original section!')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error restoring item: $e')));
    }
  }

  void _hardDeleteRecycledItem(RecycledItem item) async {
    final isHighRisk = item.entityType == 'fleet_owner' || item.entityType == 'organization';
    final TextEditingController textController = TextEditingController();
    bool isTypedValid = !isHighRisk;

    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminTheme.surface,
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'PERMANENTLY DELETE ${item.entityTypeLabel.toUpperCase()}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to PERMANENTLY delete ${item.entityTypeLabel} "${item.title}" from the cloud database?',
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Text(
                        '⚠️ WARNING: This will permanently destroy the record in PostgreSQL and purge Authentication credentials. This action CANNOT be undone.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isHighRisk) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'To confirm permanent deletion, please type DELETE below:',
                        style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textController,
                        onChanged: (val) {
                          setDialogState(() {
                            isTypedValid = val.trim() == 'DELETE';
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Type DELETE to confirm',
                          fillColor: AdminTheme.background,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isTypedValid
                      ? () => Navigator.of(ctx, rootNavigator: true).pop(true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.withOpacity(0.3),
                  ),
                  child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      try {
        await context.read<RecycleBinProvider>().hardDeleteItem(item.entityType, item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🗑️ ${item.entityTypeLabel} "${item.title}" permanently deleted from database.')),
          );
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error purging item: $e')));
      }
    }
  }
}
