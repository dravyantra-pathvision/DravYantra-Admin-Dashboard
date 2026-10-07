import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../../app/theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/audit_provider.dart';
import '../models/system_audit_log_model.dart';

class AuditDashboardScreen extends StatefulWidget {
  const AuditDashboardScreen({Key? key}) : super(key: key);

  @override
  _AuditDashboardScreenState createState() => _AuditDashboardScreenState();
}

class _AuditDashboardScreenState extends State<AuditDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  
  final List<String> _modules = [
    'All',
    'Authentication',
    'Organization',
    'Fleet Owner',
    'Device',
    'Vehicle',
    'Driver',
    'Trip',
    'Alerts',
    'Fleet Settings',
    'Subscription',
    'Billing',
    'Support'
  ];
  String _selectedModule = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().fetchLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<AuditProvider>().setFilter(
      module: _selectedModule,
      query: _searchController.text,
    );
  }

  Future<void> _exportData() async {
    try {
      final csvData = await context.read<AuditProvider>().exportLogs();
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'audit_logs_${DateTime.now().toIso8601String()}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e'), backgroundColor: AdminTheme.danger),
      );
    }
  }

  void _showDiffDialog(SystemAuditLog log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Audit Log Details', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Module', log.module),
                  _buildDetailRow('Action', log.action),
                  _buildDetailRow('Timestamp', _dateFormat.format(log.timestamp.toLocal())),
                  _buildDetailRow('User', log.userName ?? log.userEmail ?? 'Unknown'),
                  _buildDetailRow('IP Address', log.ipAddress ?? 'N/A'),
                  _buildDetailRow('Browser', log.browser ?? 'N/A'),
                  const Divider(height: 32),
                  if (log.oldValue != null) ...[
                    Text('Old Value:', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(const JsonEncoder.withIndent('  ').convert(log.oldValue), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (log.newValue != null) ...[
                    Text('New Value:', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(const JsonEncoder.withIndent('  ').convert(log.newValue), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textOnSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Center & Audit Logs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textOnSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<AuditProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: LoadingWidget());
                  }
                  if (provider.error != null) {
                    return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
                  }
                  if (provider.logs.isEmpty) {
                    return Center(child: Text('No audit logs found.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)));
                  }
                  return _buildDataTable(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final cardColor = Theme.of(context).cardColor;
    final dividerColor = Theme.of(context).dividerColor;
    final textOnSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dividerColor),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textOnSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by user email or name',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(8),
                color: cardColor,
              ),
              child: DropdownButton<String>(
                value: _selectedModule,
                dropdownColor: cardColor,
                style: TextStyle(color: textOnSurface, fontSize: 14),
                items: _modules.map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: textOnSurface)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedModule = val; });
                    _onSearch();
                  }
                },
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedModule = 'All';
              });
              context.read<AuditProvider>().clearFilters();
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filters'),
          ),
          ElevatedButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(AuditProvider provider) {
    final cardColor = Theme.of(context).cardColor;
    final dividerColor = Theme.of(context).dividerColor;
    final textOnSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(cardColor),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  columns: [
                    DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, color: textOnSurface))),
                    DataColumn(label: Text('Module', style: TextStyle(fontWeight: FontWeight.bold, color: textOnSurface))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: textOnSurface))),
                    DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold, color: textOnSurface))),
                    DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold, color: textOnSurface))),
                  ],
                  rows: provider.logs.map((log) {
                    return DataRow(cells: [
                      DataCell(Text(_dateFormat.format(log.timestamp.toLocal()), style: TextStyle(color: textOnSurface))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(log.module, style: const TextStyle(color: AdminTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataCell(Text(log.action, style: TextStyle(color: textOnSurface))),
                      DataCell(Text(log.userName ?? log.userEmail ?? 'Unknown', style: TextStyle(color: textOnSurface))),
                      DataCell(
                        InkWell(
                          onTap: () => _showDiffDialog(log),
                          child: const Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 16, color: AdminTheme.primary),
                              SizedBox(width: 4),
                              Text('View', style: TextStyle(color: AdminTheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${provider.logs.length} entries',
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
