import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import '../models/system_settings_model.dart';
import '../../../app/theme.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'general', 
    'notifications', 
    'security', 
    'thresholds', 
    'integrations', 
    'system'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AdminTheme.card,
              title: Text('Edit ${setting.key}', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(setting.description, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valueController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'New Value',
                        filled: true,
                        fillColor: AdminTheme.surface,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Reason for change (Required)',
                        filled: true,
                        fillColor: AdminTheme.surface,
                      ),
                    ),
                    if (setting.requiresSuperAdmin) ...[
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Requires Super Admin privileges.',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Please provide a reason for the change.')),
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          
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

                          setState(() => isLoading = false);
                          
                          if (success) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Setting updated successfully.')),
                            );
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Failed: ${provider.error}')),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHistoryDialog(SystemSetting setting) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AdminTheme.card,
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('History: ${setting.key}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<SettingHistory>>(
                    future: context.read<SettingsProvider>().getHistoryFor(setting.key),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                      }
                      final history = snapshot.data ?? [];
                      if (history.isEmpty) {
                        return const Center(child: Text('No history found.', style: TextStyle(color: Colors.white70)));
                      }
                      return ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final h = history[index];
                          return ListTile(
                            title: Text('Changed to: ${h.newValue}', style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              'By: ${h.changedByEmail ?? h.changedBy}\nDate: ${h.changedAt}\nReason: ${h.changeReason}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsList(List<SystemSetting> settings) {
    if (settings.isEmpty) {
      return const Center(child: Text('No settings in this category.', style: TextStyle(color: Colors.white70)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settings.length,
      itemBuilder: (context, index) {
        final setting = settings[index];
        return Card(
          color: AdminTheme.surface,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(setting.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${setting.description}\nValue: ${setting.isSensitive ? '********' : setting.value}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (setting.requiresSuperAdmin)
                  const Tooltip(
                    message: 'Requires Super Admin',
                    child: Icon(Icons.security, color: Colors.orange, size: 20),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.blueAccent),
                  tooltip: 'View History',
                  onPressed: () => _showHistoryDialog(setting),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  tooltip: 'Edit Setting',
                  onPressed: () => _showUpdateDialog(setting),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AdminTheme.background,
      appBar: AppBar(
        backgroundColor: AdminTheme.card,
        title: const Text('System Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
        ),
      ),
      body: provider.isLoading && provider.groupedSettings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && provider.groupedSettings.isEmpty
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final settings = provider.groupedSettings[tab] ?? [];
                    return _buildSettingsList(settings);
                  }).toList(),
                ),
    );
  }
}
