import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../providers/reports_provider.dart';
import '../../organizations/services/organizations_service.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form state
  String _reportType = 'Fleet Summary Report';
  String _format = 'PDF';
  String _deliveryType = 'Download Now';
  String _scheduleType = 'Daily';
  final _emailCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  List<dynamic> _orgs = [];
  String? _selectedOrgId;

  final List<String> _reportTypes = [
    'Fleet Summary Report',
    'Vehicle Report',
    'Driver Report',
    'Trip Report',
    'Fuel Consumption Report',
    'Fuel Theft Report',
    'Idle Time Report',
    'Alert Report',
    'Organization Report',
    'Device Health Report',
    'Carbon Reduction Report',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().fetchHistory();
      context.read<ReportsProvider>().fetchSchedules();
      _loadOrgs();
    });
  }

  Future<void> _loadOrgs() async {
    try {
      final orgs = await OrganizationsService().getOrganizations();
      if (mounted) setState(() => _orgs = orgs);
    } catch (e) {
      debugPrint('Failed to load orgs: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ReportsProvider>();
    final filters = <String, dynamic>{};
    if (_selectedOrgId != null) filters['organization_id'] = _selectedOrgId;
    if (_plateCtrl.text.trim().isNotEmpty) filters['vehicle_plate'] = _plateCtrl.text.trim();

    if (_deliveryType == 'Download Now') {
      final success = await provider.generateReport(_reportType, _format, filters);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Report generated! Go to History tab to download.'),
              backgroundColor: AdminTheme.success,
            ),
          );
          _tabController.animateTo(2);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed: ${provider.error ?? "Unknown error"}'),
              backgroundColor: AdminTheme.danger,
            ),
          );
        }
      }
    } else {
      final emails = _emailCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final success = await provider.scheduleReport(
          _reportType, _format, _scheduleType, emails, filters);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Report scheduled!'),
              backgroundColor: AdminTheme.success,
            ),
          );
          _tabController.animateTo(1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed: ${provider.error ?? "Unknown error"}'),
              backgroundColor: AdminTheme.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: AdminTheme.card,
            border: Border(bottom: BorderSide(color: AdminTheme.border)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports & Export Center',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AdminTheme.textPrimary)),
                  const SizedBox(height: 2),
                  const Text('Generate, schedule, and download platform-wide reports',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),

        // ── Tabs ──────────────────────────────────────────────────────────────
        Container(
          color: AdminTheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AdminTheme.primary,
            unselectedLabelColor: AdminTheme.textSecondary,
            indicatorColor: AdminTheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: const [
              Tab(icon: Icon(Icons.add_chart, size: 18), text: 'Generate Report'),
              Tab(icon: Icon(Icons.schedule, size: 18), text: 'Scheduled'),
              Tab(icon: Icon(Icons.history, size: 18), text: 'History'),
            ],
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGenerateTab(),
              _buildScheduledTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Generate Tab ────────────────────────────────────────────────────────────
  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Report Type card
                _SectionCard(
                  title: 'Report Configuration',
                  icon: Icons.tune,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _reportType,
                      decoration: const InputDecoration(
                          labelText: 'Report Type', prefixIcon: Icon(Icons.description_outlined)),
                      dropdownColor: AdminTheme.surface,
                      items: _reportTypes
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t,
                                    style: const TextStyle(
                                        color: AdminTheme.textPrimary, fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _reportType = v!),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Filters card
                _SectionCard(
                  title: 'Filters (Optional)',
                  icon: Icons.filter_list,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedOrgId,
                            decoration: const InputDecoration(
                                labelText: 'Organization',
                                prefixIcon: Icon(Icons.business_outlined)),
                            dropdownColor: AdminTheme.surface,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Organizations',
                                    style: TextStyle(
                                        color: AdminTheme.textPrimary, fontSize: 14)),
                              ),
                              ..._orgs.map(
                                (o) => DropdownMenuItem<String>(
                                  value: o['uid'],
                                  child: Text(
                                    o['company_name'] ?? o['uid'],
                                    style: const TextStyle(
                                        color: AdminTheme.textPrimary, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _selectedOrgId = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _plateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Plate',
                              hintText: 'e.g. KA 33',
                              prefixIcon: Icon(Icons.directions_car_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Format & delivery
                _SectionCard(
                  title: 'Export & Delivery',
                  icon: Icons.send_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _format,
                            decoration: const InputDecoration(
                                labelText: 'Export Format',
                                prefixIcon: Icon(Icons.file_present_outlined)),
                            dropdownColor: AdminTheme.surface,
                            items: [
                              _fmtItem('PDF', Icons.picture_as_pdf),
                              _fmtItem('Excel', Icons.table_chart),
                              _fmtItem('CSV', Icons.data_array),
                            ],
                            onChanged: (v) => setState(() => _format = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _deliveryType,
                            decoration: const InputDecoration(
                                labelText: 'Delivery Method',
                                prefixIcon: Icon(Icons.cloud_download_outlined)),
                            dropdownColor: AdminTheme.surface,
                            items: ['Download Now', 'Schedule automated email']
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t,
                                          style: const TextStyle(
                                              color: AdminTheme.textPrimary, fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _deliveryType = v!),
                          ),
                        ),
                      ],
                    ),

                    if (_deliveryType != 'Download Now') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminTheme.background,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AdminTheme.primary.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule,
                                    color: AdminTheme.primary, size: 16),
                                const SizedBox(width: 8),
                                const Text('Schedule Settings',
                                    style: TextStyle(
                                        color: AdminTheme.primary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _scheduleType,
                                    decoration: const InputDecoration(
                                        labelText: 'Frequency',
                                        prefixIcon: Icon(Icons.repeat)),
                                    dropdownColor: AdminTheme.card,
                                    items: ['Daily', 'Weekly', 'Monthly']
                                        .map((t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(t,
                                                  style: const TextStyle(
                                                      color: AdminTheme.textPrimary)),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _scheduleType = v!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Recipients',
                                      hintText: 'user1@email.com, user2@email.com',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (v) =>
                                        _deliveryType != 'Download Now' &&
                                                (v == null || v.trim().isEmpty)
                                            ? 'Enter at least one email'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // Submit button
                Consumer<ReportsProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : _submitForm,
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Icon(_deliveryType == 'Download Now'
                                ? Icons.download_rounded
                                : Icons.schedule_send),
                        label: Text(
                          provider.isLoading
                              ? 'Processing...'
                              : _deliveryType == 'Download Now'
                                  ? 'Generate & Download'
                                  : 'Save Schedule',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _fmtItem(String val, IconData icon) {
    return DropdownMenuItem<String>(
      value: val,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AdminTheme.primary),
          const SizedBox(width: 8),
          Text(val, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }

  // ── Scheduled Tab ───────────────────────────────────────────────────────────
  Widget _buildScheduledTab() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.schedules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_outlined,
                    size: 64, color: AdminTheme.textMuted),
                const SizedBox(height: 16),
                const Text('No scheduled reports',
                    style: TextStyle(color: AdminTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Go to Generate tab and choose "Schedule automated email"',
                    style: TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchSchedules,
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.schedules.length,
            itemBuilder: (context, i) {
              final s = provider.schedules[i];
              return _ScheduleCard(
                schedule: s,
                onDelete: () => _confirmDelete(
                    context, 'Delete Schedule', 'Delete this scheduled report?',
                    () => provider.deleteSchedule(s.id)),
              );
            },
          ),
        );
      },
    );
  }

  // ── History Tab ─────────────────────────────────────────────────────────────
  Widget _buildHistoryTab() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: AdminTheme.textMuted),
                const SizedBox(height: 16),
                const Text('No reports generated yet',
                    style: TextStyle(color: AdminTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Generate your first report in the Generate Report tab',
                    style: TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.history.length,
            itemBuilder: (context, i) {
              final h = provider.history[i];
              return _HistoryCard(
                report: h,
                onDownload: () => provider.downloadReport(h.fileUrl),
                onDelete: () => _confirmDelete(
                    context, 'Delete Report', 'Delete this report file permanently?',
                    () => provider.deleteHistory(h.id)),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.card,
        title: Text(title, style: const TextStyle(color: AdminTheme.textPrimary)),
        content: Text(message, style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, color: AdminTheme.primary, size: 18),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AdminTheme.border, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic report;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _HistoryCard(
      {required this.report, required this.onDownload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final Color fmtColor = report.format == 'PDF'
        ? AdminTheme.danger
        : report.format == 'Excel'
            ? AdminTheme.success
            : AdminTheme.info;
    final IconData fmtIcon = report.format == 'PDF'
        ? Icons.picture_as_pdf
        : report.format == 'Excel'
            ? Icons.table_chart
            : Icons.data_array;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: fmtColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(fmtIcon, color: fmtColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.reportType,
                    style: const TextStyle(
                        color: AdminTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${report.format} • Generated ${DateFormat("MMM dd, yyyy HH:mm").format(report.generatedAt.toLocal())}',
                  style: const TextStyle(
                      color: AdminTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AdminTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(report.status,
                style: const TextStyle(
                    color: AdminTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          // Download button
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.download_rounded, color: AdminTheme.primary),
            onPressed: onDownload,
          ),
          // Delete button
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: AdminTheme.danger),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback onDelete;

  const _ScheduleCard({required this.schedule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.schedule_rounded, color: AdminTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.reportType,
                    style: const TextStyle(
                        color: AdminTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${schedule.scheduleType} • ${schedule.format} • Next: ${DateFormat("MMM dd, HH:mm").format(schedule.nextRunAt.toLocal())}',
                  style: const TextStyle(
                      color: AdminTheme.textSecondary, fontSize: 12),
                ),
                if (schedule.emailRecipients.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '📧 ${schedule.emailRecipients.join(", ")}',
                    style: const TextStyle(
                        color: AdminTheme.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: schedule.isActive
                  ? AdminTheme.success.withOpacity(0.15)
                  : AdminTheme.textMuted.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              schedule.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  color:
                      schedule.isActive ? AdminTheme.success : AdminTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Delete Schedule',
            icon: const Icon(Icons.delete_outline, color: AdminTheme.danger),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
