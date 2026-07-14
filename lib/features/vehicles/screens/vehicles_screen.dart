import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../providers/vehicles_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesProvider>().loadVehicles(resetPage: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Vehicle Monitoring', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<VehiclesProvider>().loadVehicles(resetPage: true);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search & Filters
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by Plate, Device, or Make',
                      hintStyle: const TextStyle(color: AdminTheme.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                      filled: true,
                      fillColor: AdminTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) {
                      context.read<VehiclesProvider>().setSearchQuery(val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: AdminTheme.surface),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: InputBorder.none,
                      ),
                      isExpanded: true,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      value: context.watch<VehiclesProvider>().selectedStatus,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Statuses')),
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
                        DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (val) {
                        context.read<VehiclesProvider>().setFilters(status: val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<VehiclesProvider>().clearFilters();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Data Table
            Expanded(
            child: Consumer<VehiclesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error.isNotEmpty) {
                  return Center(
                    child: Text('Error: ${provider.error}', style: const TextStyle(color: Colors.red)),
                  );
                }

                if (provider.vehicles.isEmpty) {
                  return const Center(child: Text('No vehicles found.'));
                }

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            showCheckboxColumn: false,
                      columns: const [
                        DataColumn(label: Text('Vehicle No.', style: TextStyle(color: AdminTheme.textSecondary))),
                        DataColumn(label: Text('Organization', style: TextStyle(color: AdminTheme.textSecondary))),
                        DataColumn(label: Text('Owner Email', style: TextStyle(color: AdminTheme.textSecondary))),
                        DataColumn(label: Text('Make/Model', style: TextStyle(color: AdminTheme.textSecondary))),
                        DataColumn(label: Text('Device ID', style: TextStyle(color: AdminTheme.textSecondary))),
                        DataColumn(label: Text('Status', style: TextStyle(color: AdminTheme.textSecondary))),
                        DataColumn(label: Text('Actions', style: TextStyle(color: AdminTheme.textSecondary))),
                      ],
                      rows: provider.vehicles.map((vehicle) {
                        return DataRow(
                          onSelectChanged: (_) {
                            context.go('/vehicles/${vehicle.plate}');
                          },
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(vehicle.plate, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                                  if (_hasExpiredDocs(vehicle)) ...[
                                    const SizedBox(width: 8),
                                    const Tooltip(
                                      message: 'Documents Expiring/Expired',
                                      child: Icon(Icons.warning, color: Colors.orange, size: 16),
                                    )
                                  ]
                                ],
                              ),
                            ),
                            DataCell(Text(vehicle.organizationName ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                            DataCell(Text(vehicle.fleetOwnerEmail ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                            DataCell(Text('${vehicle.make ?? '-'} ${vehicle.model ?? '-'}', style: const TextStyle(color: AdminTheme.textPrimary))),
                            DataCell(Text(vehicle.deviceId ?? 'Not Assigned', style: const TextStyle(color: AdminTheme.textPrimary))),
                            DataCell(_buildStatusBadge(vehicle.status ?? 'Unknown')),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {
                                  context.go('/vehicles/${vehicle.plate}');
                                },
                                tooltip: 'View Details',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            );
                },
              ),
            ),

          // Pagination
          Consumer<VehiclesProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Total: ${provider.totalVehicles}', style: const TextStyle(color: AdminTheme.textPrimary)),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AdminTheme.textSecondary),
                      onPressed: provider.currentPage > 1 ? provider.previousPage : null,
                    ),
                    Text('Page ${provider.currentPage}', style: const TextStyle(color: AdminTheme.textPrimary)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AdminTheme.textSecondary),
                      onPressed: (provider.currentPage * provider.limit) < provider.totalVehicles
                          ? provider.nextPage
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  bool _hasExpiredDocs(vehicle) {
    final now = DateTime.now();
    if (vehicle.insuranceExpiry != null && vehicle.insuranceExpiry!.isBefore(now)) return true;
    if (vehicle.rcExpiry != null && vehicle.rcExpiry!.isBefore(now)) return true;
    if (vehicle.fitnessExpiry != null && vehicle.fitnessExpiry!.isBefore(now)) return true;
    if (vehicle.pucExpiry != null && vehicle.pucExpiry!.isBefore(now)) return true;
    return false;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
