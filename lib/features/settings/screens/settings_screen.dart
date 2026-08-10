import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../settings_provider.dart';
import '../models/system_settings_model.dart';
import '../../../app/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'general',
      'label': 'General & Org',
      'icon': Icons.tune_rounded,
      'desc': 'Platform identity, timezone, currency, and language preferences',
    },
    {
      'key': 'notifications',
      'label': 'Alerts & Channels',
      'icon': Icons.notifications_active_outlined,
      'desc': 'Real-time alert channels, WhatsApp, SMS, and email rules',
    },
    {
      'key': 'security',
      'label': 'Security & Auth',
      'icon': Icons.security_rounded,
      'desc': '2FA, session timeouts, and Super Admin access restrictions',
    },
    {
      'key': 'thresholds',
      'label': 'Fleet Thresholds',
      'icon': Icons.speed_rounded,
      'desc': 'Speed limits, fuel theft sensitivity, and idling timeouts',
    },
    {
      'key': 'integrations',
      'label': 'Cloud & APIs',
      'icon': Icons.cloud_done_outlined,
      'desc': 'AWS S3 storage, Twilio gateways, and external API keys',
    },
    {
      'key': 'system',
      'label': 'System & Maintenance',
      'icon': Icons.dns_rounded,
      'desc': 'Maintenance mode, database backups, and telemetry polling',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
            _buildHeader(provider),
            const SizedBox(height: 24),
            _buildCategoryTabs(),
            const SizedBox(height: 20),
            if (provider.isLoading && provider.groupedSettings.isEmpty)
              const SizedBox(
                height: 350,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null && provider.groupedSettings.isEmpty)
              _buildErrorView(provider.error!)
            else
              _buildActiveTabContent(provider),
          ],
        ),
      ),
    );
  }

  // ── Header Banner ──────────────────────────────────────────────────────────
  Widget _buildHeader(SettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings_suggest_rounded, color: AdminTheme.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Settings & Admin Control',
                        style: TextStyle(color: AdminTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage global parameters, alert rules, cloud integrations, and system safety defaults',
                        style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: provider.isLoading ? null : () => provider.fetchSettings(),
                icon: provider.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Sync Settings'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AdminTheme.border, height: 1),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildStatusChip('Cloud Storage: AWS S3 (Active)', Icons.cloud_done, AdminTheme.success),
              _buildStatusChip('Database: AWS RDS PostgreSQL', Icons.storage, AdminTheme.info),
              _buildStatusChip('Security Policy: Enforced', Icons.admin_panel_settings, AdminTheme.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Tab Bar Navigation ─────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AdminTheme.primary,
        indicatorWeight: 3,
        labelColor: AdminTheme.primary,
        unselectedLabelColor: AdminTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: _categories.map((cat) {
          return Tab(
            child: Row(
              children: [
                Icon(cat['icon'] as IconData, size: 18),
                const SizedBox(width: 8),
                Text(cat['label'] as String),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Tab Content Container ──────────────────────────────────────────────────
  Widget _buildActiveTabContent(SettingsProvider provider) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final catKey = _categories[_tabController.index]['key'] as String;
        final catDesc = _categories[_tabController.index]['desc'] as String;
        final catLabel = _categories[_tabController.index]['label'] as String;

        // Extract settings for this category
        final List<SystemSetting> categorySettings = provider.groupedSettings[catKey] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Description Bar & Filter Search
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(catLabel, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(catDesc, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Filter category settings...',
                        hintStyle: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AdminTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: AdminTheme.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Card Items
            _buildFilteredSettingsList(categorySettings),
          ],
        );
      },
    );
  }

  Widget _buildFilteredSettingsList(List<SystemSetting> settings) {
    final filtered = settings.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.key.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery) ||
          (s.value != null && s.value.toString().toLowerCase().contains(_searchQuery));
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AdminTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune_sharp, size: 40, color: AdminTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty ? 'No settings match "$_searchQuery"' : 'No configured parameters in this category yet.',
              style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final setting = filtered[index];
        return _buildSettingCard(setting);
      },
    );
  }

  // ── Individual Setting Card Item ──────────────────────────────────────────
  Widget _buildSettingCard(SystemSetting setting) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon indicator based on category/key
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconForKey(setting.key), color: AdminTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),

          // Setting Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatKeyName(setting.key),
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AdminTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: Text(
                        setting.key,
                        style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                    if (setting.requiresSuperAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AdminTheme.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AdminTheme.warning.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security, color: AdminTheme.warning, size: 12),
                            SizedBox(width: 4),
                            Text('Super Admin', style: TextStyle(color: AdminTheme.warning, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  setting.description.isNotEmpty ? setting.description : 'No description specified for this system setting.',
                  style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Current Value Visual Representation
                if (!isBoolValue)
                  Row(
                    children: [
                      const Text('Current Value: ', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AdminTheme.border),
                        ),
                        child: Text(
                          setting.isSensitive ? '••••••••••••' : _formatValueDisplay(setting.value),
                          style: TextStyle(
                            color: setting.isSensitive ? AdminTheme.warning : AdminTheme.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      if (setting.updatedAt != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Last changed ${DateFormat('MMM dd, yyyy HH:mm').format(setting.updatedAt!)}',
                          style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Actions / Control Widget
          if (isBoolValue)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: boolVal,
                  activeColor: AdminTheme.success,
                  onChanged: (newVal) => _quickToggleBoolean(setting, newVal),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AdminTheme.info, size: 20),
                  tooltip: 'View History',
                  onPressed: () => _showHistoryDialog(setting),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AdminTheme.info, size: 20),
                  tooltip: 'Audit History',
                  onPressed: () => _showHistoryDialog(setting),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.surface,
                    foregroundColor: AdminTheme.textPrimary,
                    side: const BorderSide(color: AdminTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AdminTheme.primary),
                  label: const Text('Edit', style: TextStyle(fontSize: 13)),
                  onPressed: () => _showUpdateDialog(setting),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Quick Toggle for Boolean Settings ──────────────────────────────────────
  Future<void> _quickToggleBoolean(SystemSetting setting, bool newVal) async {
    final provider = context.read<SettingsProvider>();
    final success = await provider.updateSetting(
      key: setting.key,
      value: newVal,
      category: setting.category,
      reason: 'Quick toggle via Admin Settings Panel to $newVal',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_formatKeyName(setting.key)} set to ${newVal ? "ENABLED" : "DISABLED"}')),
      );
    }
  }

  // ── Edit Setting Dialog ────────────────────────────────────────────────────
  void _showUpdateDialog(SystemSetting setting) {
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
                  const Icon(Icons.edit_note_rounded, color: AdminTheme.primary),
                  const SizedBox(width: 10),
                  Text('Update ${_formatKeyName(setting.key)}', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.description.isNotEmpty ? setting.description : 'System parameter configuration',
                      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valueController,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Setting Value',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                      maxLines: setting.isSensitive ? 1 : 3,
                      obscureText: setting.isSensitive,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Audit Reason (Required for system logs)',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                    ),
                    if (setting.requiresSuperAdmin) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AdminTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AdminTheme.warning.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AdminTheme.warning, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Requires Super Admin privileges to apply.',
                                style: TextStyle(color: AdminTheme.warning, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
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
                              const SnackBar(content: Text('Please provide an audit reason for the change.')),
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

                          if (success && mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Setting updated successfully.')),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Failed: ${provider.error}')),
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

  // ── Audit History Modal ────────────────────────────────────────────────────
  void _showHistoryDialog(SystemSetting setting) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AdminTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 700,
            height: 500,
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
                        Text('Audit Timeline: ${_formatKeyName(setting.key)}', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
                          child: Text('No previous audit log history recorded for this parameter.', style: TextStyle(color: AdminTheme.textSecondary)),
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
                              color: AdminTheme.surface,
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
                                      'Value: ${h.newValue}',
                                      style: const TextStyle(color: AdminTheme.success, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      h.changedAt != null ? DateFormat('MMM dd, yyyy HH:mm').format(h.changedAt!) : '—',
                                      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Changed by: ${h.changedByEmail ?? h.changedBy ?? "Admin"}',
                                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12),
                                ),
                                if (h.changeReason != null && h.changeReason!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reason: "${h.changeReason}"',
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

  Widget _buildErrorView(String err) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.danger.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AdminTheme.danger),
            const SizedBox(height: 12),
            Text('Error loading system settings: $err', style: const TextStyle(color: AdminTheme.danger, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ── Utility Formatting Helpers ─────────────────────────────────────────────
  String _formatKeyName(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('.', ' / ')
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

  IconData _getIconForKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('speed')) return Icons.speed_rounded;
    if (k.contains('fuel') || k.contains('theft')) return Icons.local_gas_station_rounded;
    if (k.contains('idle') || k.contains('time')) return Icons.timer_outlined;
    if (k.contains('email') || k.contains('mail')) return Icons.email_outlined;
    if (k.contains('phone') || k.contains('sms') || k.contains('whatsapp')) return Icons.phone_android_rounded;
    if (k.contains('security') || k.contains('auth') || k.contains('2fa')) return Icons.security_rounded;
    if (k.contains('s3') || k.contains('storage') || k.contains('aws')) return Icons.cloud_outlined;
    if (k.contains('db') || k.contains('database') || k.contains('backup')) return Icons.storage_rounded;
    return Icons.tune_rounded;
  }
}
