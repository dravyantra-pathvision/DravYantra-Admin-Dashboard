import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme.dart';
import '../services/devices_service.dart';
import '../widgets/register_device_dialog.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final _service = DevicesService();
  bool _isLoading = true;
  List<dynamic> _devices = [];
  
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getDevices(
        search: _searchQuery,
        status: _filterStatus,
      );
      if (!mounted) return;
      setState(() {
        _devices = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Available': return Colors.green;
      case 'Assigned': return Colors.blue;
      case 'Online': return Colors.teal;
      case 'Offline': return Colors.red;
      case 'Maintenance': return Colors.orange;
      case 'Retired': return Colors.grey;
      case 'Inactive': return Colors.grey.shade400;
      default: return Colors.blue;
    }
  }

  void _showRegisterDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const RegisterDeviceDialog(),
    );
    if (result != null) {
      try {
        setState(() => _isLoading = true);
        await _service.registerDevice(result);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device registered successfully!'), backgroundColor: Colors.green));
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showDetails(String deviceId) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _service.getDeviceDetail(deviceId),
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
            
            final device = snapshot.data!;
            final logs = (device['audit_logs'] as List<dynamic>?) ?? [];
            
            return AlertDialog(
              backgroundColor: AdminTheme.surface,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Device Details', style: TextStyle(color: AdminTheme.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(device['status']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      device['status'] ?? 'Unknown',
                      style: TextStyle(color: _getStatusColor(device['status']), fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              content: SizedBox(
                width: 700,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hardware Specs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                const SizedBox(height: 8),
                                _buildDetailRow('Device ID', device['device_id']),
                                _buildDetailRow('Serial Number', device['serial_number']),
                                _buildDetailRow('Manufacturer', device['manufacturer']),
                                _buildDetailRow('Device Type', device['device_type']),
                                _buildDetailRow('Hardware Ver', device['hardware_version']),
                                _buildDetailRow('Firmware Ver', device['firmware_version']),
                                const Divider(),
                                const Text('Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                const SizedBox(height: 8),
                                _buildDetailRow('Vehicle', device['assigned_vehicle'] ?? 'Unassigned'),
                                _buildDetailRow('Organization', device['org_name'] ?? 'Unassigned'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const Text('QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: QrImageView(
                                    data: device['device_id'] ?? '',
                                    version: QrVersions.auto,
                                    size: 150.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Audit Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary)),
                      const SizedBox(height: 8),
                      logs.isEmpty ? const Text('No activity yet.', style: TextStyle(color: AdminTheme.textSecondary)) : 
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return ListTile(
                            leading: const Icon(Icons.history, color: AdminTheme.primary),
                            title: Text(log['action'] ?? '', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
                            subtitle: Text(log['remarks'] ?? '', style: const TextStyle(color: AdminTheme.textSecondary)),
                            trailing: Text(log['created_at'].toString().split('T')[0], style: const TextStyle(color: AdminTheme.textMuted)),
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                if (device['status'] != 'Retired')
                  TextButton(
                    onPressed: () {
                      _service.updateDeviceStatus(device['device_id'], 'Retired').then((_) {
                        Navigator.of(dialogContext, rootNavigator: true).pop();
                        _fetchData();
                      });
                    },
                    child: const Text('Retire Device', style: TextStyle(color: Colors.red)),
                  ),
                TextButton(onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Device Inventory', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              ElevatedButton.icon(
                onPressed: _showRegisterDialog,
                icon: const Icon(Icons.add),
                label: const Text('Register Device'),
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (v) { _searchQuery = v; },
                    onSubmitted: (_) => _fetchData(),
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by Device ID or Serial',
                      hintStyle: const TextStyle(color: AdminTheme.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                      filled: true,
                      fillColor: AdminTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: AdminTheme.surface),
                    child: DropdownButtonFormField<String>(
                      value: _filterStatus,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12), border: InputBorder.none),
                      isExpanded: true,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      items: ['All', 'Available', 'Assigned', 'Online', 'Offline', 'Maintenance', 'Retired']
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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _fetchData,
                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12)),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              headingTextStyle: const TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.bold),
                              dataTextStyle: const TextStyle(color: AdminTheme.textPrimary),
                              columns: const [
                          DataColumn(label: Text('Device ID')),
                          DataColumn(label: Text('Firmware')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Vehicle')),
                          DataColumn(label: Text('Org')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _devices.map((device) {
                          return DataRow(
                            cells: [
                              DataCell(Text(device['device_id']?.toString() ?? 'N/A')),
                              DataCell(Text(device['firmware_version']?.toString() ?? 'N/A')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(device['status']).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    device['status']?.toString() ?? 'Unknown',
                                    style: TextStyle(color: _getStatusColor(device['status']), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(Text(device['assigned_vehicle']?.toString() ?? 'N/A')),
                              DataCell(Text(device['org_name']?.toString() ?? 'N/A')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blue),
                                  tooltip: 'View Details',
                                  onPressed: () => _showDetails(device['device_id']),
                                ),
                              ),
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
    );
  }
}
