import 'package:flutter/material.dart';
import 'dart:async';
import '../../../app/theme.dart';
import '../services/fleet_owners_service.dart';

class FleetOwnersScreen extends StatefulWidget {
  const FleetOwnersScreen({super.key});

  @override
  State<FleetOwnersScreen> createState() => _FleetOwnersScreenState();
}

class _FleetOwnersScreenState extends State<FleetOwnersScreen> {
  late FleetOwnersService _service;
  bool _isLoading = true;
  List<dynamic> _fleetOwners = [];
  
  String _filterAccountStatus = 'All';
  String _filterOrgStatus = 'All';
  String _searchQuery = '';
  Timer? _debounce;
  
  int _page = 1;
  int _limit = 50;

  @override
  void initState() {
    super.initState();
    _service = FleetOwnersService();
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
          _page = 1; // reset page on search
        });
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final accountStatus = _filterAccountStatus == 'All' ? null : _filterAccountStatus;
      final orgStatus = _filterOrgStatus == 'All' ? null : _filterOrgStatus;
      
      final data = await _service.getFleetOwners(
        search: _searchQuery, 
        status: accountStatus, 
        orgStatus: orgStatus,
        page: _page,
        limit: _limit
      );
      
      setState(() {
        _fleetOwners = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching fleet owners: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load fleet owners')));
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Active':
      case 'Approved':
        return Colors.green;
      case 'Pending Review':
        return Colors.orange;
      case 'Suspended':
      case 'Inactive':
        return Colors.grey;
      case 'Deleted':
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showDetails(String uid) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _service.getFleetOwnerDetail(uid),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return AlertDialog(
                backgroundColor: AdminTheme.surface,
                title: const Text('Error', style: TextStyle(color: Colors.red)),
                content: Text('Failed to load details: ${snapshot.error}', style: const TextStyle(color: AdminTheme.textPrimary)),
                actions: [
                  TextButton(onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(), child: const Text('Close')),
                ],
              );
            }
            
            final details = snapshot.data!;
            final user = details['user'] ?? {};
            final org = details['org'] ?? {};
            final vehicles = details['vehicles'] ?? {};
            final drivers = details['drivers'] ?? {};
            
            return AlertDialog(
              backgroundColor: AdminTheme.surface,
              title: Text(user['full_name'] ?? 'Fleet Owner Details', style: const TextStyle(color: AdminTheme.textPrimary)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDetailRow('Account Status', user['account_status'] ?? 'Active', color: _getStatusColor(user['account_status'])),
                      _buildDetailRow('Email', user['email'] ?? 'N/A'),
                      _buildDetailRow('Phone', user['phone'] ?? 'N/A'),
                      _buildDetailRow('Created Date', user['created_at'] != null ? user['created_at'].toString().split('T')[0] : 'N/A'),
                      const Divider(),
                      const Text('Organization Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                      _buildDetailRow('Company Name', org['company_name'] ?? 'N/A'),
                      _buildDetailRow('Organization Status', org['status'] ?? 'N/A', color: _getStatusColor(org['status'])),
                      _buildDetailRow('City', org['city'] ?? 'N/A'),
                      _buildDetailRow('Fleet Size', org['fleet_size'] ?? 'N/A'),
                      const Divider(),
                      const Text('Platform Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                      _buildDetailRow('Total Vehicles', vehicles['total']?.toString() ?? '0'),
                      _buildDetailRow('Total Drivers', drivers['total']?.toString() ?? '0'),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(), child: const Text('Close')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                    _showEditDialog(details);
                  },
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> details) {
    final user = details['user'] ?? {};
    final org = details['org'] ?? {};
    
    final nameCtrl = TextEditingController(text: user['full_name']);
    final phoneText = user['phone'] != null && user['phone'].toString().isNotEmpty ? user['phone'] : '+91 ';
    final phoneCtrl = TextEditingController(text: phoneText);
    final emailCtrl = TextEditingController(text: user['email']);
    final companyCtrl = TextEditingController(text: org['company_name']);
    String statusVal = user['account_status'] ?? 'Active';
    
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              backgroundColor: AdminTheme.surface,
              title: const Text('Edit Fleet Owner', style: TextStyle(color: AdminTheme.textPrimary)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Owner Name'), style: const TextStyle(color: AdminTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), style: const TextStyle(color: AdminTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), style: const TextStyle(color: AdminTheme.textPrimary)),
                      const SizedBox(height: 8),
                      TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company Name'), style: const TextStyle(color: AdminTheme.textPrimary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: statusVal,
                        dropdownColor: AdminTheme.surface,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Account Status'),
                        items: ['Active', 'Suspended', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setStateSB(() => statusVal = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (!RegExp(r'^\+91 [6-9]\d{9}$').hasMatch(phoneCtrl.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone must be +91 followed by 10 digits starting with 6-9'), backgroundColor: Colors.red));
                      return;
                    }
                    try {
                      await _service.updateFleetOwner(user['uid'], {
                        'full_name': nameCtrl.text,
                        'phone': phoneCtrl.text,
                        'email': emailCtrl.text,
                        'organization_name': companyCtrl.text,
                        'account_status': statusVal,
                      });
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully')));
                        _fetchData();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _resetPassword(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.surface,
        title: const Text('Reset Password', style: TextStyle(color: AdminTheme.textPrimary)),
        content: const Text('Are you sure you want to generate a password reset email for this user?', style: TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Reset')),
        ],
      )
    );
    
    if (confirm == true) {
      try {
        await _service.resetPassword(uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email initiated.')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _deleteFleetOwner(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.surface,
        title: const Text('Delete Fleet Owner', style: TextStyle(color: AdminTheme.textPrimary)),
        content: const Text('Are you sure you want to soft delete this fleet owner?', style: TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      )
    );
    
    if (confirm == true) {
      try {
        await _service.deleteFleetOwner(uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
          _fetchData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _updateStatusAction(String uid, String actionStatus) async {
    try {
      await _service.updateStatus(uid, actionStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $actionStatus')));
        _fetchData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(color: color ?? AdminTheme.textPrimary, fontWeight: color != null ? FontWeight.bold : FontWeight.normal))),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fleet Owners', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by Name, Email, or Organization',
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
                      value: _filterAccountStatus,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12), border: InputBorder.none),
                      isExpanded: true,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      items: ['All', 'Active', 'Suspended', 'Deleted']
                          .map((e) => DropdownMenuItem(value: e, child: Text('Account: $e', overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _filterAccountStatus = v);
                          _fetchData();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: AdminTheme.surface),
                    child: DropdownButtonFormField<String>(
                      value: _filterOrgStatus,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12), border: InputBorder.none),
                      isExpanded: true,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      items: ['All', 'Approved', 'Pending Review', 'Rejected', 'Suspended']
                          .map((e) => DropdownMenuItem(value: e, child: Text('Org: $e', overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _filterOrgStatus = v);
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
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _fleetOwners.isEmpty
                      ? const Center(child: Text('No fleet owners found', style: TextStyle(color: AdminTheme.textSecondary)))
                      : SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Name', style: TextStyle(color: AdminTheme.textSecondary))),
                                      DataColumn(label: Text('Email', style: TextStyle(color: AdminTheme.textSecondary))),
                                      DataColumn(label: Text('Organization', style: TextStyle(color: AdminTheme.textSecondary))),
                                      DataColumn(label: Text('Account Status', style: TextStyle(color: AdminTheme.textSecondary))),
                                      DataColumn(label: Text('Org Status', style: TextStyle(color: AdminTheme.textSecondary))),
                                      DataColumn(label: Text('Vehicles', style: TextStyle(color: AdminTheme.textSecondary))),
                                      DataColumn(label: Text('Actions', style: TextStyle(color: AdminTheme.textSecondary))),
                                    ],
                                    rows: _fleetOwners.map((owner) {
                                      final uid = owner['uid']?.toString() ?? '';
                                      final status = owner['account_status'] ?? 'Active';
                                      
                                      return DataRow(cells: [
                                        DataCell(Text(owner['full_name'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold))),
                                        DataCell(Text(owner['email'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                        DataCell(Text(owner['company_name'] ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                        DataCell(Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold))),
                                        DataCell(Text(owner['organization_status'] ?? 'N/A', style: TextStyle(color: _getStatusColor(owner['organization_status'])))),
                                        DataCell(Text(owner['vehicle_count']?.toString() ?? '0', style: const TextStyle(color: AdminTheme.textPrimary))),
                                        DataCell(Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), tooltip: 'View Details', onPressed: () => _showDetails(uid)),
                                            if (status != 'Deleted')
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert, color: AdminTheme.textSecondary),
                                                color: AdminTheme.surface,
                                                onSelected: (value) {
                                                  if (value == 'suspend') _updateStatusAction(uid, 'Suspended');
                                                  else if (value == 'activate') _updateStatusAction(uid, 'Active');
                                                  else if (value == 'reset') _resetPassword(uid);
                                                  else if (value == 'delete') _deleteFleetOwner(uid);
                                                },
                                                itemBuilder: (context) => [
                                                  if (status == 'Active') const PopupMenuItem(value: 'suspend', child: Text('Suspend Account', style: TextStyle(color: Colors.orange))),
                                                  if (status == 'Suspended') const PopupMenuItem(value: 'activate', child: Text('Activate Account', style: TextStyle(color: Colors.green))),
                                                  const PopupMenuItem(value: 'reset', child: Text('Reset Password', style: TextStyle(color: AdminTheme.textPrimary))),
                                                  const PopupMenuItem(value: 'delete', child: Text('Delete Account', style: TextStyle(color: Colors.red))),
                                                ],
                                              ),
                                          ],
                                        )),
                                      ]);
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
