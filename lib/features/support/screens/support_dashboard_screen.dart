import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/support_provider.dart';
import '../models/ticket_model.dart';
import '../../../app/theme.dart';

class SupportDashboardScreen extends StatefulWidget {
  const SupportDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SupportDashboardScreen> createState() => _SupportDashboardScreenState();
}

class _SupportDashboardScreenState extends State<SupportDashboardScreen> {
  String _selectedStatus = '';
  String _selectedPriority = '';
  String _selectedCategory = '';

  final List<String> _statuses = ['', 'Open', 'In Progress', 'Resolved', 'Closed', 'Reopened', 'Escalated'];
  final List<String> _priorities = ['', 'Low', 'Medium', 'High', 'Urgent'];
  final List<String> _categories = [
    '', 'Technical', 'Billing', 'Hardware', 'Account',
    'Fleet', 'Trips', 'Fuel Sensor', 'GPS', 'Device Replacement'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SupportProvider>();
      p.fetchTickets();
      p.fetchAnalytics();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open': return AdminTheme.info;
      case 'In Progress': return AdminTheme.warning;
      case 'Resolved': return AdminTheme.success;
      case 'Closed': return AdminTheme.textMuted;
      case 'Escalated': return AdminTheme.danger;
      case 'Reopened': return AdminTheme.secondary;
      default: return AdminTheme.textSecondary;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Urgent': return AdminTheme.danger;
      case 'High': return AdminTheme.warning;
      case 'Medium': return AdminTheme.info;
      case 'Low': return AdminTheme.success;
      default: return AdminTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupportProvider>();

    return Scaffold(
      backgroundColor: AdminTheme.background,
      appBar: AppBar(
        backgroundColor: AdminTheme.card,
        title: const Text('Support & Tickets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Analytics strip
          if (provider.analytics != null) _buildAnalyticsStrip(provider.analytics!),

          // Filters
          _buildFilters(),

          // Table
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
                    : provider.tickets.isEmpty
                        ? _buildEmpty()
                        : _buildTicketsTable(provider.tickets),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsStrip(SupportAnalytics analytics) {
    final items = [
      _StatItem('Total', analytics.total.toString(), AdminTheme.primary),
      _StatItem('Open', (analytics.byStatus['Open'] ?? 0).toString(), AdminTheme.info),
      _StatItem('In Progress', (analytics.byStatus['In Progress'] ?? 0).toString(), AdminTheme.warning),
      _StatItem('Escalated', (analytics.byStatus['Escalated'] ?? 0).toString(), AdminTheme.danger),
      _StatItem('Resolved', (analytics.byStatus['Resolved'] ?? 0).toString(), AdminTheme.success),
    ];

    return Container(
      color: AdminTheme.card,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: items.map((item) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(item.value, style: TextStyle(color: item.color, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(item.label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    final dropdownStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AdminTheme.surface),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );

    return Container(
      color: AdminTheme.card,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _filterDropdown('Status', _selectedStatus, _statuses, (v) {
            setState(() => _selectedStatus = v ?? '');
            context.read<SupportProvider>().setFilters(
              status: _selectedStatus, priority: _selectedPriority, category: _selectedCategory);
          }),
          const SizedBox(width: 8),
          _filterDropdown('Priority', _selectedPriority, _priorities, (v) {
            setState(() => _selectedPriority = v ?? '');
            context.read<SupportProvider>().setFilters(
              status: _selectedStatus, priority: _selectedPriority, category: _selectedCategory);
          }),
          const SizedBox(width: 8),
          _filterDropdown('Category', _selectedCategory, _categories, (v) {
            setState(() => _selectedCategory = v ?? '');
            context.read<SupportProvider>().setFilters(
              status: _selectedStatus, priority: _selectedPriority, category: _selectedCategory);
          }),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              setState(() { _selectedStatus = ''; _selectedPriority = ''; _selectedCategory = ''; });
              context.read<SupportProvider>().setFilters();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      dropdownColor: AdminTheme.card,
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      hint: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      items: options.map((o) => DropdownMenuItem(
        value: o,
        child: Text(o.isEmpty ? 'All $label' : o),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTicketsTable(List<SupportTicket> tickets) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: tickets.map((ticket) => _buildTicketCard(ticket)).toList(),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return GestureDetector(
      onTap: () => context.go('/support/${ticket.ticketNumber}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(ticket.ticketNumber,
                    style: TextStyle(color: AdminTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                _chip(ticket.status, _statusColor(ticket.status)),
                const SizedBox(width: 8),
                _chip(ticket.priority, _priorityColor(ticket.priority)),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(ticket.createdAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket.subject,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business, size: 13, color: Colors.white54),
                const SizedBox(width: 4),
                Text(ticket.organizationName ?? 'Unknown Org',
                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 13, color: Colors.white54),
                const SizedBox(width: 4),
                Text(ticket.fleetOwnerName ?? ticket.fleetOwnerEmail ?? 'Unknown',
                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 13, color: Colors.white54),
                const SizedBox(width: 4),
                Text(ticket.category, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                if (ticket.assignedStaffName != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.support_agent, size: 13, color: AdminTheme.success.withOpacity(0.8)),
                  const SizedBox(width: 4),
                  Text(ticket.assignedStaffName!,
                      style: TextStyle(color: AdminTheme.success.withOpacity(0.8), fontSize: 12)),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 64, color: AdminTheme.textMuted),
          const SizedBox(height: 16),
          Text('No support tickets', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          Text('All tickets will appear here', style: TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  _StatItem(this.label, this.value, this.color);
}
