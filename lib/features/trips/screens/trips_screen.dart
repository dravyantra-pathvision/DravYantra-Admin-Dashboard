import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../providers/trips_provider.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().fetchTrips(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildStatusBadge(String status) {
    Color bg, text;
    final s = status.toLowerCase();
    if (s == 'completed') {
      bg = Colors.green.withOpacity(0.1);
      text = Colors.green;
    } else if (s == 'running' || s == 'started') {
      bg = Colors.blue.withOpacity(0.1);
      text = Colors.blue;
    } else if (s == 'cancelled') {
      bg = Colors.red.withOpacity(0.1);
      text = Colors.red;
    } else {
      bg = Colors.grey.withOpacity(0.1);
      text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _exportCSV() async {
    try {
      final bytes = await context.read<TripsProvider>().exportTrips();
      if (bytes.isNotEmpty) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'trips_export.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trip Monitoring', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search trips...',
                        hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary, size: 18),
                        filled: true,
                        fillColor: AdminTheme.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) {
                        context.read<TripsProvider>().setSearchQuery(val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export CSV'),
                    onPressed: _exportCSV,
                  ),
                ],
              )
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: 250,
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: AdminTheme.surface),
              child: DropdownButtonFormField<String>(
                value: context.watch<TripsProvider>().statusFilter,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: AdminTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                isExpanded: true,
                style: const TextStyle(color: AdminTheme.textPrimary),
                items: ['All', 'Running', 'Completed', 'Cancelled', 'Scheduled']
                    .map((status) => DropdownMenuItem(value: status, child: Text('Status: $status')))
                    .toList(),
                onChanged: (status) {
                  if (status != null) {
                    context.read<TripsProvider>().setStatusFilter(status);
                  }
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Consumer<TripsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.trips.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.trips.isEmpty) {
                  return Center(child: Text(provider.error!, style: const TextStyle(color: AdminTheme.danger)));
                }

                if (provider.trips.isEmpty) {
                  return const Center(child: Text('No trips found', style: TextStyle(color: AdminTheme.textSecondary)));
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            showCheckboxColumn: false,
                            columns: const [
                              DataColumn(label: Expanded(child: Text('Trip ID', style: TextStyle(color: AdminTheme.textSecondary)))),
                              DataColumn(label: Expanded(child: Text('Organization', style: TextStyle(color: AdminTheme.textSecondary)))),
                              DataColumn(label: Expanded(child: Text('Vehicle No.', style: TextStyle(color: AdminTheme.textSecondary)))),
                              DataColumn(label: Expanded(child: Text('Driver Name', style: TextStyle(color: AdminTheme.textSecondary)))),
                              DataColumn(label: Expanded(child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary)))),
                              DataColumn(label: Expanded(child: Text('Distance', style: TextStyle(color: AdminTheme.textSecondary)))),
                              DataColumn(label: Expanded(child: Text('Actions', style: TextStyle(color: AdminTheme.textSecondary)))),
                            ],
                            rows: provider.trips.map((trip) {
                              return DataRow(
                                onSelectChanged: (_) {
                                  context.go('/trips/${trip.id}');
                                },
                                cells: [
                                  DataCell(Text(trip.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary))),
                                  DataCell(Text(trip.organizationName ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(Text(trip.vehicle ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(Text(trip.driver ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(_buildStatusBadge(trip.status ?? 'Unknown')),
                                  DataCell(Text('${trip.distance?.toStringAsFixed(1) ?? '0.0'} km', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue),
                                      onPressed: () => context.go('/trips/${trip.id}'),
                                      tooltip: 'View Details',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    if (provider.trips.length < provider.totalTrips)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: () => provider.loadNextPage(),
                          child: provider.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Load More', style: TextStyle(color: AdminTheme.primary)),
                        ),
                      )
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
