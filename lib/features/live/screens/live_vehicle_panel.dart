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
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
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
    final textOnSurface = Theme.of(context).colorScheme.onSurface;
    final cardColor     = Theme.of(context).cardColor;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Real-Time Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textOnSurface)),
          const SizedBox(height: 24),
          
          // Fleet filter — dynamically loaded from backend
          _buildFleetDropdown(context, provider),
          const SizedBox(height: 16),

          _buildFilterDropdown(
            context,
            'Status', 
            provider.statusFilter, 
            ['All', 'Moving', 'Idle', 'Parked', 'Offline'], 
            (v) => provider.setFilters(status: v)
          ),
          const SizedBox(height: 16),
          
          _buildFilterDropdown(
            context,
            'Alerts', 
            provider.alertFilter, 
            ['All', 'critical', 'fuel_theft', 'overspeed'], 
            (v) => provider.setFilters(alertFilter: v)
          ),
          const SizedBox(height: 16),
          
          TextField(
            style: TextStyle(color: textOnSurface, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Search Vehicle / Driver',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => provider.setFilters(search: v),
          ),
          
          const Spacer(),
          Text('Select a vehicle on the map to view detailed live telemetry.', 
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFleetDropdown(BuildContext context, LiveProvider provider) {
    final fleets = provider.fleetList;
    final selectedUid = provider.selectedFleetUid;
    final textOnSurface = Theme.of(context).colorScheme.onSurface;
    final cardColor     = Theme.of(context).cardColor;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Fleet',
        prefixIcon: Icon(Icons.business),
      ),
      value: selectedUid.isEmpty ? '' : selectedUid,
      isExpanded: true,
      dropdownColor: cardColor,
      style: TextStyle(color: textOnSurface, fontSize: 14),
      items: [
        DropdownMenuItem<String>(value: '', child: Text('All Fleets', style: TextStyle(color: textOnSurface))),
        ...fleets.map((fleet) {
          final vehicleCount = fleet['vehicle_count'] ?? 0;
          return DropdownMenuItem<String>(
            value: fleet['uid'] as String,
            child: Text(
              '${fleet['company_name']} ($vehicleCount)',
              style: TextStyle(color: textOnSurface),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: (uid) => provider.setFilters(fleetUid: uid ?? ''),
    );
  }

  Widget _buildFilterDropdown(BuildContext context, String label, String current, List<String> options, Function(String?) onChanged) {
    final textOnSurface = Theme.of(context).colorScheme.onSurface;
    final cardColor     = Theme.of(context).cardColor;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
      ),
      value: current,
      dropdownColor: cardColor,
      style: TextStyle(color: textOnSurface, fontSize: 14),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: TextStyle(color: textOnSurface)))).toList(),
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
    final textOnSurface = Theme.of(context).colorScheme.onSurface;
    final cardColor     = Theme.of(context).cardColor;
    final dividerColor  = Theme.of(context).dividerColor;
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(bottom: BorderSide(color: dividerColor)),
          ),
          child: Row(
            children: [
              IconButton(icon: Icon(Icons.close, color: textOnSurface), onPressed: () => provider.selectVehicle(null)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle['plate'] ?? 'Unknown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textOnSurface)),
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
              _buildSectionTitle(context, 'Organization Info'),
              _buildInfoRow(context, 'Organization', vehicle['organization_name'] ?? 'N/A'),
              _buildInfoRow(context, 'Fleet Owner', vehicle['fleet_owner_name'] ?? 'N/A'),
              _buildInfoRow(context, 'Driver', vehicle['driver_name'] ?? 'N/A'),
              
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Live Telemetry'),
              _buildInfoRow(context, 'Speed', '${vehicle['speed'] ?? 0} km/h'),
              _buildInfoRow(context, 'Fuel Level', '${vehicle['fuel'] ?? 0}%'),
              _buildInfoRow(context, 'GPS Status', vehicle['gps_status'] ?? 'Unknown'),
              _buildInfoRow(context, 'Device Battery', '${vehicle['battery_level'] ?? 0}%'),
              _buildInfoRow(context, 'Signal', '${vehicle['signal_strength'] ?? 0}%'),
              _buildInfoRow(context, 'Heartbeat', vehicle['last_heartbeat'] != null ? DateTime.parse(vehicle['last_heartbeat']).toLocal().toString().split('.')[0] : 'Never'),
              
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Current Trip'),
              _buildInfoRow(context, 'Trip ID', vehicle['trip_id'] ?? 'None'),
              if (vehicle['trip_id'] != null) ...[
                _buildInfoRow(context, 'Status', vehicle['trip_status'] ?? 'N/A'),
                _buildInfoRow(context, 'From', vehicle['from_location'] ?? 'N/A'),
                _buildInfoRow(context, 'To', vehicle['to_location'] ?? 'N/A'),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
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
