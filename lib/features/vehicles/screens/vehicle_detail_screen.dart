import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../providers/vehicles_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String plate;

  const VehicleDetailScreen({super.key, required this.plate});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesProvider>().loadVehicleDetail(widget.plate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      appBar: AppBar(
        title: Text('Vehicle: ${widget.plate}'),
        backgroundColor: AdminTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/vehicles'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Documents'),
            Tab(text: 'Telemetry & Device'),
            Tab(text: 'Audit Logs'),
          ],
        ),
      ),
      body: Consumer<VehiclesProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error.isNotEmpty && provider.currentVehicleDetail == null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          final vehicle = provider.currentVehicleDetail;
          if (vehicle == null) {
            return const Center(child: Text('Vehicle not found.'));
          }

          return Column(
            children: [
              _buildHeader(context, vehicle),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(vehicle),
                    _buildDocumentsTab(vehicle),
                    _buildTelemetryTab(vehicle),
                    _buildLogsTab(provider.currentAuditLogs),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, vehicle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, size: 48, color: AdminTheme.textSecondary),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.plate, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                  Text(vehicle.organizationName ?? 'No Organization', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 16)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildStatusBadge(vehicle.status ?? 'Unknown'),
              const SizedBox(width: 16),
              if (vehicle.status == 'Active')
                ElevatedButton.icon(
                  icon: const Icon(Icons.block),
                  label: const Text('Block Vehicle'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () => _showActionDialog(context, 'block'),
                ),
              if (vehicle.status == 'Active') const SizedBox(width: 8),
              if (vehicle.status == 'Active')
                ElevatedButton.icon(
                  icon: const Icon(Icons.pause),
                  label: const Text('Suspend'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  onPressed: () => _showActionDialog(context, 'suspend'),
                ),
              if (vehicle.status == 'Blocked' || vehicle.status == 'Suspended')
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Reactivate'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () {
                    context.read<VehiclesProvider>().reactivateVehicle(vehicle.plate);
                  },
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOverviewTab(vehicle) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThemeCard(
          title: 'Fleet Owner Details',
          content: [
            'Name: ${vehicle.fleetOwnerName ?? 'N/A'}',
            'Email: ${vehicle.fleetOwnerEmail ?? 'N/A'}',
            'Phone: ${vehicle.fleetOwnerPhone ?? 'N/A'}',
          ],
        ),
        _buildThemeCard(
          title: 'Vehicle Info',
          content: [
            'Make: ${vehicle.make ?? 'N/A'}',
            'Model: ${vehicle.model ?? 'N/A'} (${vehicle.year ?? 'N/A'})',
            'Type: ${vehicle.type ?? 'N/A'}',
            'Fuel Type: ${vehicle.fuelType ?? 'N/A'} (Capacity: ${vehicle.fuelCapacity ?? 'N/A'}L)',
          ],
        ),
        _buildThemeCard(
          title: 'Driver Details',
          content: [
            'Name: ${vehicle.driverName ?? 'Not Assigned'}',
            if (vehicle.driverPhone != null) 'Phone: ${vehicle.driverPhone}',
          ],
        ),
      ],
    );
  }

  Widget _buildThemeCard({required String title, required List<String> content}) {
    return Card(
      color: AdminTheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AdminTheme.textPrimary)),
            const SizedBox(height: 12),
            ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(text, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 15)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab(vehicle) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _docTile('Insurance Expiry', vehicle.insuranceExpiry),
        _docTile('RC Expiry', vehicle.rcExpiry),
        _docTile('Fitness Certificate Expiry', vehicle.fitnessExpiry),
        _docTile('PUC Expiry', vehicle.pucExpiry),
      ],
    );
  }

  Widget _docTile(String title, DateTime? expiryDate) {
    bool isExpired = false;
    bool isMissing = expiryDate == null;
    if (!isMissing && expiryDate.isBefore(DateTime.now())) {
      isExpired = true;
    }
    
    IconData icon;
    Color color;
    
    if (isMissing) {
      icon = Icons.pending_actions;
      color = Colors.orange;
    } else if (isExpired) {
      icon = Icons.error;
      color = Colors.red;
    } else {
      icon = Icons.check_circle;
      color = Colors.green;
    }
    
    return Card(
      color: AdminTheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: AdminTheme.textPrimary)),
        trailing: Text(
          isMissing ? 'Not Provided' : DateFormat('yyyy-MM-dd').format(expiryDate!),
          style: TextStyle(
            color: color,
            fontWeight: isExpired || isMissing ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryTab(vehicle) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThemeCard(
          title: 'Device Information',
          content: [
            'Device ID: ${vehicle.deviceId ?? 'Not Assigned'}',
            'Device Status: ${vehicle.deviceStatus ?? 'N/A'}',
            'Last Communication: ${vehicle.lastCommunication != null ? DateFormat('yyyy-MM-dd HH:mm').format(vehicle.lastCommunication!) : 'Never'}',
          ],
        ),
        _buildThemeCard(
          title: 'Live Telemetry',
          content: [
            'Speed: ${vehicle.speed != null ? '${vehicle.speed} km/h' : 'N/A'}',
            'Fuel Level: ${vehicle.fuel != null ? '${vehicle.fuel}%' : 'N/A'}',
            'Location (Lat, Lng): ${vehicle.lat != null && vehicle.lng != null ? '${vehicle.lat}, ${vehicle.lng}' : 'N/A'}',
          ],
        ),
      ],
    );
  }

  Widget _buildLogsTab(List logs) {
    if (logs.isEmpty) {
      return const Center(child: Text('No audit logs for this vehicle.', style: TextStyle(color: AdminTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          color: AdminTheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.history, color: AdminTheme.textSecondary),
            title: Text('${log.action} - ${DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt)}', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason: ${log.reason ?? '-'}', style: const TextStyle(color: AdminTheme.textSecondary)),
                  Text('Remarks: ${log.remarks ?? '-'}', style: const TextStyle(color: AdminTheme.textSecondary)),
                  Text('By: ${log.adminName ?? log.adminEmail ?? 'Admin'}', style: const TextStyle(color: AdminTheme.textSecondary)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'blocked':
        color = Colors.red;
        break;
      case 'suspended':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showActionDialog(BuildContext context, String action) async {
    final reasonController = TextEditingController();
    final remarksController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminTheme.surface,
          title: Text(action == 'block' ? 'Block Vehicle' : 'Suspend Vehicle', style: const TextStyle(color: AdminTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Reason', 
                  labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AdminTheme.border)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Remarks', 
                  labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AdminTheme.border)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: action == 'block' ? Colors.red : Colors.orange),
              onPressed: () {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason is required')));
                  return;
                }
                if (action == 'block') {
                  context.read<VehiclesProvider>().blockVehicle(widget.plate, reasonController.text, remarksController.text);
                } else {
                  context.read<VehiclesProvider>().suspendVehicle(widget.plate, reasonController.text, remarksController.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
