import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../providers/live_provider.dart';

class LiveVehiclePanel extends StatelessWidget {
  const LiveVehiclePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, provider, child) {
        final vehicle = provider.selectedVehicle;
        
        return Container(
          decoration: const BoxDecoration(
            color: AdminTheme.surface,
            border: Border(left: BorderSide(color: AdminTheme.border)),
          ),
          child: vehicle == null 
              ? const _FiltersPanel() 
              : _VehicleDetailPanel(vehicle: vehicle),
        );
      },
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LiveProvider>();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Real-Time Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
          const SizedBox(height: 24),
          
          // Fleet filter — dynamically loaded from backend
          _buildFleetDropdown(provider),
          const SizedBox(height: 16),

          _buildFilterDropdown(
            'Status', 
            provider.statusFilter, 
            ['All', 'Moving', 'Idle', 'Parked', 'Offline'], 
            (v) => provider.setFilters(status: v)
          ),
          const SizedBox(height: 16),
          
          _buildFilterDropdown(
            'Alerts', 
            provider.alertFilter, 
            ['All', 'critical', 'fuel_theft', 'overspeed'], 
            (v) => provider.setFilters(alertFilter: v)
          ),
          const SizedBox(height: 16),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Vehicle / Driver',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => provider.setFilters(search: v),
          ),
          
          const Spacer(),
          const Text('Select a vehicle on the map to view detailed live telemetry.', 
            style: TextStyle(color: AdminTheme.textSecondary, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFleetDropdown(LiveProvider provider) {
    final fleets = provider.fleetList;
    final selectedUid = provider.selectedFleetUid;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Fleet',
        prefixIcon: Icon(Icons.business),
        border: OutlineInputBorder(),
      ),
      value: selectedUid.isEmpty ? '' : selectedUid,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('All Fleets')),
        ...fleets.map((fleet) {
          final vehicleCount = fleet['vehicle_count'] ?? 0;
          return DropdownMenuItem<String>(
            value: fleet['uid'] as String,
            child: Text(
              '${fleet['company_name']} ($vehicleCount)',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: (uid) => provider.setFilters(fleetUid: uid ?? ''),
    );
  }

  Widget _buildFilterDropdown(String label, String current, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: current,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
      onChanged: onChanged,
    );
  }
}

class _VehicleDetailPanel extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const _VehicleDetailPanel({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LiveProvider>();
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AdminTheme.surface,
            border: Border(bottom: BorderSide(color: AdminTheme.border)),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.close), onPressed: () => provider.selectVehicle(null)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle['plate'] ?? 'Unknown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                    Text(vehicle['status'] ?? 'Offline', style: TextStyle(fontSize: 14, color: _getStatusColor(vehicle['status']))),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Organization Info'),
              _buildInfoRow('Organization', vehicle['organization_name'] ?? 'N/A'),
              _buildInfoRow('Fleet Owner', vehicle['fleet_owner_name'] ?? 'N/A'),
              _buildInfoRow('Driver', vehicle['driver_name'] ?? 'N/A'),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Live Telemetry'),
              _buildInfoRow('Speed', '${vehicle['speed'] ?? 0} km/h'),
              _buildInfoRow('Fuel Level', '${vehicle['fuel'] ?? 0}%'),
              _buildInfoRow('GPS Status', vehicle['gps_status'] ?? 'Unknown'),
              _buildInfoRow('Device Battery', '${vehicle['battery_level'] ?? 0}%'),
              _buildInfoRow('Signal', '${vehicle['signal_strength'] ?? 0}%'),
              _buildInfoRow('Heartbeat', vehicle['last_heartbeat'] != null ? DateTime.parse(vehicle['last_heartbeat']).toLocal().toString().split('.')[0] : 'Never'),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Current Trip'),
              _buildInfoRow('Trip ID', vehicle['trip_id'] ?? 'None'),
              if (vehicle['trip_id'] != null) ...[
                _buildInfoRow('Status', vehicle['trip_status'] ?? 'N/A'),
                _buildInfoRow('From', vehicle['from_location'] ?? 'N/A'),
                _buildInfoRow('To', vehicle['to_location'] ?? 'N/A'),
              ],
              
              const SizedBox(height: 32),
              const Text('Emergency Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.danger)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.block, color: AdminTheme.danger),
                label: const Text('Block Vehicle', style: TextStyle(color: AdminTheme.danger)),
                onPressed: () {},
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AdminTheme.danger)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AdminTheme.textPrimary)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'moving': return AdminTheme.success;
      case 'idle': return AdminTheme.warning;
      case 'parked': return AdminTheme.info;
      default: return AdminTheme.textSecondary;
    }
  }
}
