import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/support_provider.dart';
import '../models/ticket_model.dart';
import '../../../app/theme.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketNumber;
  const TicketDetailScreen({super.key, required this.ticketNumber});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _messageController = TextEditingController();
  Timer? _pollingTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().fetchTicketDetail(widget.ticketNumber);
    });
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollTicket());
  }

  Future<void> _pollTicket() async {
    if (!mounted) return;
    try {
      final provider = context.read<SupportProvider>();
      await provider.fetchTicketDetail(widget.ticketNumber, showLoading: false);
    } catch (e) {
      // Ignore background errors
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) return;
    setState(() => _isSending = true);
    final success = await context.read<SupportProvider>().addMessage(widget.ticketNumber, msg);
    setState(() => _isSending = false);
    if (success) {
      _messageController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<SupportProvider>().error ?? 'Failed to send message')));
      }
    }
  }

  void _showUpdateDialog(SupportTicket ticket) {
    String selectedStatus = ticket.status;
    String selectedPriority = ticket.priority;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => AlertDialog(
          backgroundColor: AdminTheme.surface,
          title: const Text('Update Ticket', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                dropdownColor: AdminTheme.surface,
                style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated', 'Reopened']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setS(() => selectedStatus = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                dropdownColor: AdminTheme.surface,
                style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['Low', 'Medium', 'High', 'Urgent']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setS(() => selectedPriority = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await context.read<SupportProvider>().updateTicket(
                  widget.ticketNumber,
                  status: selectedStatus,
                  priority: selectedPriority,
                );
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket updated successfully.')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupportProvider>();

    if (provider.isDetailLoading) {
      return const Scaffold(
        backgroundColor: AdminTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ticket = provider.selectedTicket;
    if (ticket == null) {
      return Scaffold(
        backgroundColor: AdminTheme.background,
        appBar: AppBar(
          backgroundColor: AdminTheme.surface,
          title: Text(widget.ticketNumber, style: const TextStyle(color: AdminTheme.textPrimary)),
        ),
        body: const Center(child: Text('Ticket not found', style: TextStyle(color: AdminTheme.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AdminTheme.background,
      appBar: AppBar(
        backgroundColor: AdminTheme.surface,
        elevation: 1,
        shadowColor: const Color(0x0F0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.ticketNumber, style: const TextStyle(color: AdminTheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(ticket.subject, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showUpdateDialog(ticket),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Update'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left: Chat History
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: ticket.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.chat_bubble_outline, size: 48, color: AdminTheme.textMuted),
                              SizedBox(height: 12),
                              Text('No messages yet', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: ticket.messages.length,
                          itemBuilder: (context, index) => _buildMessageBubble(ticket.messages[index]),
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
          // Right: Ticket Details Panel
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: AdminTheme.surface,
              border: Border(left: BorderSide(color: AdminTheme.border, width: 1.2)),
            ),
            child: _buildDetailPanel(ticket),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TicketMessage msg) {
    final isAdmin = msg.senderRole == 'admin';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminTheme.info.withOpacity(0.15),
              child: Text((msg.senderName ?? 'F')[0].toUpperCase(),
                  style: const TextStyle(color: AdminTheme.info, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(msg.senderName ?? 'Unknown',
                        style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text(DateFormat('dd MMM, hh:mm a').format(msg.createdAt),
                        style: const TextStyle(color: AdminTheme.textMuted, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? AdminTheme.primary.withOpacity(0.12)
                        : AdminTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAdmin ? AdminTheme.primary.withOpacity(0.3) : AdminTheme.border,
                      width: 1.2,
                    ),
                    boxShadow: AdminTheme.cardShadow,
                  ),
                  child: Text(
                    msg.message,
                    style: TextStyle(
                      color: isAdmin ? AdminTheme.primaryDark : AdminTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminTheme.primary.withOpacity(0.15),
              child: const Icon(Icons.support_agent, size: 16, color: AdminTheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AdminTheme.surface,
        border: Border(top: BorderSide(color: AdminTheme.border, width: 1.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              style: const TextStyle(color: AdminTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(color: AdminTheme.textMuted),
                filled: true,
                fillColor: AdminTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AdminTheme.border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AdminTheme.border, width: 1.2),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSending ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            child: _isSending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(SupportTicket ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('TICKET DETAILS'),
          const SizedBox(height: 12),
          _detailRow('Ticket #', ticket.ticketNumber),
          _detailRow('Status', ticket.status, valueColor: _statusColor(ticket.status)),
          _detailRow('Priority', ticket.priority, valueColor: _priorityColor(ticket.priority)),
          _detailRow('Category', ticket.category),
          const Divider(color: AdminTheme.border, height: 24, thickness: 1.2),
          _sectionTitle('CUSTOMER'),
          const SizedBox(height: 12),
          _detailRow('Organization', ticket.organizationName ?? 'N/A'),
          _detailRow('Fleet Owner', ticket.fleetOwnerName ?? 'N/A'),
          _detailRow('Email', ticket.fleetOwnerEmail ?? 'N/A'),
          const Divider(color: AdminTheme.border, height: 24, thickness: 1.2),
          _sectionTitle('ASSIGNMENT'),
          const SizedBox(height: 12),
          _detailRow('Assigned To', ticket.assignedStaffName ?? 'Unassigned'),
          const Divider(color: AdminTheme.border, height: 24, thickness: 1.2),
          _sectionTitle('TIMELINE'),
          const SizedBox(height: 12),
          _detailRow('Created', DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt)),
          if (ticket.resolvedAt != null)
            _detailRow('Resolved', DateFormat('dd MMM yyyy, hh:mm a').format(ticket.resolvedAt!)),
          const SizedBox(height: 24),
          _sectionTitle('QUICK ACTIONS'),
          const SizedBox(height: 12),
          ...['Resolved', 'Closed', 'Escalated', 'Reopened'].map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final ok = await context.read<SupportProvider>().updateTicket(
                    ticket.ticketNumber, status: s);
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ticket marked as $s')));
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _statusColor(s),
                  backgroundColor: AdminTheme.surface,
                  side: BorderSide(color: _statusColor(s).withOpacity(0.4), width: 1.2),
                ),
                child: Text('Mark as $s', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AdminTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
