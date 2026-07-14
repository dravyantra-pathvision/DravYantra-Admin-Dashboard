import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../models/alert_model.dart';
import '../providers/alerts_provider.dart';

class AlertDetailPanel extends StatefulWidget {
  const AlertDetailPanel({super.key});

  @override
  State<AlertDetailPanel> createState() => _AlertDetailPanelState();
}

class _AlertDetailPanelState extends State<AlertDetailPanel> {
  final _noteCtrl = TextEditingController();
  bool _showNoteInput = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
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
      case 'new':         return AdminTheme.danger;
      case 'acknowledged':return AdminTheme.warning;
      case 'in progress': return AdminTheme.info;
      case 'resolved':    return AdminTheme.success;
      case 'dismissed':   return AdminTheme.textSecondary;
      default:            return AdminTheme.textSecondary;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'viewed':        return Icons.visibility;
      case 'acknowledged':  return Icons.check_circle;
      case 'status_changed':return Icons.swap_horiz;
      case 'comment':       return Icons.comment;
      case 'resolved':      return Icons.done_all;
      case 'notified':      return Icons.notifications;
      default:              return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        final alert = provider.selectedAlert;

        if (provider.isDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (alert == null) {
          return _buildEmptyState();
        }

        return Container(
          color: AdminTheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, provider, alert),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAlertInfo(alert),
                      const SizedBox(height: 20),
                      _buildEntities(alert),
                      const SizedBox(height: 20),
                      if (alert.lat != null) ...[_buildLocation(alert), const SizedBox(height: 20)],
                      _buildAdminActions(context, provider, alert),
                      const SizedBox(height: 20),
                      if (_showNoteInput) ...[_buildNoteInput(context, provider, alert), const SizedBox(height: 20)],
                      if (alert.adminNotes?.isNotEmpty == true) ...[_buildNotes(alert), const SizedBox(height: 20)],
                      _buildTimeline(alert),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AdminTheme.textMuted),
          const SizedBox(height: 16),
          Text('Select an alert to view details',
              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext ctx, AlertsProvider provider, AlertModel alert) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: _severityColor(alert.severity),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(alert.type,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(alert.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor(alert.status).withOpacity(0.4)),
            ),
            child: Text(alert.status,
                style: TextStyle(color: _statusColor(alert.status), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: AdminTheme.textSecondary, size: 20),
            onPressed: () => provider.clearSelectedAlert(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertInfo(AlertModel alert) {
    return _card([
      _sectionTitle('Alert Information', Icons.info_outline),
      const SizedBox(height: 12),
      Text(alert.message, style: const TextStyle(color: AdminTheme.textSecondary, height: 1.5)),
      const SizedBox(height: 12),
      _row('Alert ID', '#${alert.id}'),
      _row('Severity', alert.severity, color: _severityColor(alert.severity)),
      _row('Priority', alert.priority ?? 'Medium'),
      _row('Source', alert.source ?? 'telemetry'),
      _row('Category', alert.category ?? '—'),
      _row('Detected', _fmt(alert.detectedAt)),
      if (alert.acknowledgedAt != null) _row('Acknowledged', _fmt(alert.acknowledgedAt!)),
      if (alert.resolvedAt != null) _row('Resolved', _fmt(alert.resolvedAt!)),
    ]);
  }

  Widget _buildEntities(AlertModel alert) {
    return _card([
      _sectionTitle('Involved Entities', Icons.link),
      const SizedBox(height: 12),
      if (alert.organizationName != null) _row('Organization', alert.organizationName!),
      if (alert.fleetOwnerName != null) _row('Fleet Owner', alert.fleetOwnerName!),
      if (alert.fleetOwnerEmail != null) _row('Email', alert.fleetOwnerEmail!),
      if (alert.vehiclePlate != null) _row('Vehicle', alert.vehiclePlate!),
      if (alert.driver != null) _row('Driver', alert.driver!),
      if (alert.deviceId != null) _row('Device ID', alert.deviceId!),
      if (alert.tripId != null) _row('Trip ID', alert.tripId!),
      if (alert.notifiedFleetOwner) _row('Fleet Notified', '✅ Yes', color: AdminTheme.success),
    ]);
  }

  Widget _buildLocation(AlertModel alert) {
    return _card([
      _sectionTitle('GPS Location', Icons.location_on),
      const SizedBox(height: 12),
      _row('Latitude', alert.lat?.toStringAsFixed(6) ?? '—'),
      _row('Longitude', alert.lng?.toStringAsFixed(6) ?? '—'),
    ]);
  }

  Widget _buildAdminActions(BuildContext ctx, AlertsProvider provider, AlertModel alert) {
    final status = alert.status.toLowerCase();

    return _card([
      _sectionTitle('Admin Actions', Icons.admin_panel_settings),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (status == 'new')
            _actionBtn('Acknowledge', Icons.check_circle_outline, AdminTheme.warning,
                () => _doAction(ctx, provider, alert.id, 'Acknowledged')),
          if (status == 'acknowledged')
            _actionBtn('Mark In Progress', Icons.pending_actions, AdminTheme.info,
                () => _doAction(ctx, provider, alert.id, 'In Progress')),
          if (status == 'in progress' || status == 'acknowledged')
            _actionBtn('Resolve', Icons.done_all, AdminTheme.success,
                () => _doAction(ctx, provider, alert.id, 'Resolved')),
          if (status != 'dismissed' && status != 'resolved')
            _actionBtn('Dismiss', Icons.cancel_outlined, AdminTheme.textSecondary,
                () => _doAction(ctx, provider, alert.id, 'Dismissed')),
          if (status == 'resolved' || status == 'dismissed')
            _actionBtn('Reopen', Icons.replay, AdminTheme.primary,
                () => _doAction(ctx, provider, alert.id, 'In Progress')),
          _actionBtn('Add Note', Icons.note_add, AdminTheme.primaryLight,
              () => setState(() => _showNoteInput = !_showNoteInput)),
          if (!alert.notifiedFleetOwner)
            _actionBtn('Notify Fleet', Icons.send, Colors.teal,
                () async {
                  final ok = await provider.notifyFleetOwner(alert.id);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(ok ? '✅ Fleet Owner notified' : '❌ Failed to notify'),
                      backgroundColor: ok ? AdminTheme.success : AdminTheme.danger,
                    ));
                  }
                }),
        ],
      ),
    ]);
  }

  Future<void> _doAction(BuildContext ctx, AlertsProvider provider, int id, String status) async {
    final ok = await provider.updateStatus(id, status);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(ok ? '✅ Status updated to $status' : '❌ Failed to update status'),
        backgroundColor: ok ? AdminTheme.success : AdminTheme.danger,
      ));
    }
  }

  Widget _buildNoteInput(BuildContext ctx, AlertsProvider provider, AlertModel alert) {
    return _card([
      _sectionTitle('Add Internal Note', Icons.edit_note),
      const SizedBox(height: 12),
      TextField(
        controller: _noteCtrl,
        maxLines: 3,
        style: const TextStyle(color: AdminTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Type your note here...',
          hintStyle: const TextStyle(color: AdminTheme.textMuted),
          filled: true,
          fillColor: AdminTheme.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AdminTheme.border)),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => setState(() { _showNoteInput = false; _noteCtrl.clear(); }),
            child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Save Note'),
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary),
            onPressed: () async {
              if (_noteCtrl.text.trim().isEmpty) return;
              final ok = await provider.addComment(alert.id, _noteCtrl.text.trim());
              if (ctx.mounted) {
                if (ok) { _noteCtrl.clear(); setState(() => _showNoteInput = false); }
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(ok ? '✅ Note saved' : '❌ Failed to save note'),
                  backgroundColor: ok ? AdminTheme.success : AdminTheme.danger,
                ));
              }
            },
          ),
        ],
      ),
    ]);
  }

  Widget _buildNotes(AlertModel alert) {
    return _card([
      _sectionTitle('Admin Notes', Icons.sticky_note_2),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AdminTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Text(alert.adminNotes ?? '',
            style: const TextStyle(color: AdminTheme.textSecondary, height: 1.6, fontFamily: 'monospace', fontSize: 12)),
      ),
    ]);
  }

  Widget _buildTimeline(AlertModel alert) {
    if (alert.auditLog.isEmpty) return const SizedBox.shrink();

    return _card([
      _sectionTitle('Activity Timeline', Icons.timeline),
      const SizedBox(height: 16),
      ...alert.auditLog.map((entry) => _timelineEntry(entry)),
    ]);
  }

  Widget _timelineEntry(AuditLogEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AdminTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_actionIcon(entry.action), size: 15, color: AdminTheme.primary),
              ),
              Container(width: 1, height: 24, color: AdminTheme.border),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatAction(entry.action),
                    style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
                if (entry.details?.isNotEmpty == true)
                  Text(entry.details!, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12, height: 1.4)),
                const SizedBox(height: 4),
                Text(_fmt(entry.createdAt), style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAction(String action) {
    switch (action) {
      case 'viewed':         return 'Alert Viewed';
      case 'acknowledged':   return 'Acknowledged';
      case 'status_changed': return 'Status Changed';
      case 'comment':        return 'Note Added';
      case 'resolved':       return 'Resolved';
      case 'notified':       return 'Fleet Owner Notified';
      default:               return action.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    }
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AdminTheme.primary, size: 16),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(color: color ?? AdminTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  String _fmt(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
