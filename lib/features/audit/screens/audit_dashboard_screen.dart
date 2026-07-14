import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../../app/theme.dart';
import '../../../shared/components/admin_sidebar.dart';
import '../../../shared/components/top_navbar.dart';
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
      final anchor = html.AnchorElement(href: url)
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
          title: const Text('Audit Log Details'),
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
                    Text('Old Value:', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(const JsonEncoder.withIndent('  ').convert(log.oldValue)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (log.newValue != null) ...[
                    Text('New Value:', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(const JsonEncoder.withIndent('  ').convert(log.newValue)),
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Center & Audit Logs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                    return const Center(child: Text('No audit logs found.'));
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by user email or name',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AdminTheme.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedModule,
                items: _modules.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedModule = val; });
                    _onSearch();
                  }
                },
              ),
            ),
          ),
          const Spacer(),
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
          const SizedBox(width: 16),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(AdminTheme.background),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Module', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: provider.logs.map((log) {
                  return DataRow(cells: [
                    DataCell(Text(_dateFormat.format(log.timestamp.toLocal()))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(log.module, style: const TextStyle(color: AdminTheme.primary, fontSize: 12)),
                      )
                    ),
                    DataCell(Text(log.action)),
                    DataCell(Text(log.userName ?? log.userEmail ?? 'System')),
                    DataCell(
                      TextButton.icon(
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View'),
                        onPressed: () => _showDiffDialog(log),
                      )
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
          _buildPagination(provider),
        ],
      ),
    );
  }

  Widget _buildPagination(AuditProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing ${provider.logs.length} of ${provider.totalItems} entries'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.currentPage > 1
                    ? () => provider.fetchLogs(page: provider.currentPage - 1)
                    : null,
              ),
              Text('Page ${provider.currentPage} of ${provider.totalPages}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: provider.currentPage < provider.totalPages
                    ? () => provider.fetchLogs(page: provider.currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
