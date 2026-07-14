import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../app/theme.dart';
import '../../authentication/providers/auth_provider.dart';
import '../services/organizations_service.dart';

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({super.key});

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  late OrganizationsService _service;
  bool _isLoading = true;
  List<dynamic> _organizations = [];
  String _filterStatus = 'All';
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _service = OrganizationsService();
    _fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
        });
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final status = _filterStatus == 'All' ? null : _filterStatus;
      final data = await _service.getOrganizations(status: status, search: _searchQuery);
      setState(() {
        _organizations = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching organizations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load organizations')));
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending Review':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'Suspended':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showOrganizationDetails(Map<String, dynamic> org) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final details = await _service.getOrganizationDetail(org['uid']);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      _showDetailsDialog(details);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load details: $e')));
    }
  }

  void _showDetailsDialog(Map<String, dynamic> details) {
    final orgData = details['org'] ?? {};
    final userData = details['user'] ?? {};
    final vehicles = details['vehicles'] ?? {};
    final drivers = details['drivers'] ?? {};
    final currentStatus = orgData['status'] ?? 'Unknown';
    final orgId = orgData['id'].toString();

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminTheme.surface,
          title: Text(orgData['company_name'] ?? 'Organization Details', style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Status', currentStatus, color: _getStatusColor(currentStatus)),
                  const Divider(),
                  _buildDetailRow('Fleet Owner Email', userData['email'] ?? 'N/A'),
                  _buildDetailRow('Fleet Owner Name', userData['full_name'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  const Text('Company Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                  _buildDetailRow('Contact Number', orgData['contact_number'] ?? 'N/A'),
                  _buildDetailRow('City', orgData['city'] ?? 'N/A'),
                  _buildDetailRow('State', orgData['state'] ?? 'N/A'),
                  _buildDetailRow('PAN', orgData['pan'] ?? 'N/A'),
                  _buildDetailRow('GSTIN', orgData['gstin'] ?? 'N/A'),
                  _buildDetailRow('Fleet Size', orgData['fleet_size'] ?? 'N/A'),
                  _buildDetailRow('Industry', orgData['industry_type'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  const Text('Platform Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                  _buildDetailRow('Total Vehicles', vehicles['total']?.toString() ?? '0'),
                  _buildDetailRow('Active Vehicles', vehicles['active']?.toString() ?? '0'),
                  _buildDetailRow('Total Drivers', drivers['total']?.toString() ?? '0'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('Close'),
            ),
            if (currentStatus == 'Pending Review' || currentStatus == 'Rejected' || currentStatus == 'Suspended')
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => _updateStatus(orgId, 'approve', context),
                child: const Text('Approve'),
              ),
            if (currentStatus == 'Pending Review')
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => _showReasonDialog(orgId, 'reject', context),
                child: const Text('Reject'),
              ),
            if (currentStatus == 'Approved')
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () => _showReasonDialog(orgId, 'suspend', context),
                child: const Text('Suspend'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(color: color ?? AdminTheme.textPrimary, fontWeight: color != null ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  void _showReasonDialog(String orgId, String action, BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.surface,
        title: Text('Reason for ${action == 'reject' ? 'Rejection' : 'Suspension'}', style: const TextStyle(color: AdminTheme.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AdminTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter reason (optional)',
            hintStyle: TextStyle(color: AdminTheme.textMuted),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: action == 'reject' ? Colors.red : Colors.orange, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop(); // close reason dialog
              _updateStatus(orgId, action, parentContext, reason: controller.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String orgId, String action, BuildContext dialogContext, {String? reason}) async {
    try {
      await _service.updateStatus(orgId, action, reason: reason?.isEmpty == true ? null : reason);
      if (mounted) {
        Navigator.of(dialogContext, rootNavigator: true).pop(); // Close details dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Organization updated successfully')));
        _fetchData(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background, // Explicitly use the dark theme background
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Organizations',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by Company, City, etc.',
                      hintStyle: const TextStyle(color: AdminTheme.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                      filled: true,
                      fillColor: AdminTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: AdminTheme.surface),
                    child: DropdownButtonFormField<String>(
                      value: _filterStatus,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12), border: InputBorder.none),
                      isExpanded: true,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      items: ['All', 'Draft', 'Pending Review', 'Approved', 'Rejected', 'Suspended']
                          .map((e) => DropdownMenuItem(value: e, child: Text('Status: $e', overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _filterStatus = v);
                          _fetchData();
                        }
                      },
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _organizations.isEmpty
                      ? const Center(child: Text('No organizations found', style: TextStyle(color: AdminTheme.textSecondary)))
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AdminTheme.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                    headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text('Company Name')),
                                      DataColumn(label: Text('Fleet Owner Name')),
                                      DataColumn(label: Text('Fleet Owner Email')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('City')),
                                      DataColumn(label: Text('Joined At')),
                                    ],
                                    rows: _organizations.map((org) {
                                      final status = org['status'] ?? 'Unknown';
                                      return DataRow(
                                        onSelectChanged: (_) => _showOrganizationDetails(org),
                                        cells: [
                                          DataCell(Text(org['company_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600))),
                                          DataCell(Text(org['full_name'] ?? 'N/A')),
                                          DataCell(Text(org['email'] ?? 'N/A')),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(org['city'] ?? 'N/A')),
                                          DataCell(Text(org['created_at']?.toString().substring(0, 10) ?? 'N/A')),
                                        ],
                                      );
                                    }).toList(),
                                  ), // closes DataTable
                                ); // closes SingleChildScrollView
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
