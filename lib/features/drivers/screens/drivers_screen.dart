import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../providers/drivers_provider.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriversProvider>().fetchDrivers(resetPage: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.red;
      case 'on leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
            const Text(
              'Drivers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AdminTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Filters & Search
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search drivers, license, phone...',
                      hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                      filled: true,
                      fillColor: AdminTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<DriversProvider>().setSearchQuery(value);
                    },
                  ),
                ),
                
                Consumer<DriversProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonContainer(
                      value: provider.selectedStatus ?? 'All',
                      items: const ['All', 'Active', 'Suspended'],
                      onChanged: (val) {
                        provider.setFilter(status: val);
                      },
                      hint: 'Status',
                    );
                  }
                ),

                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<DriversProvider>().clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.surface,
                    foregroundColor: AdminTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Data Table
            Expanded(
              child: Consumer<DriversProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error.isNotEmpty) {
                    return Center(child: Text(provider.error, style: const TextStyle(color: Colors.red)));
                  }

                  if (provider.drivers.isEmpty) {
                    return const Center(child: Text('No drivers found', style: TextStyle(color: AdminTheme.textSecondary)));
                  }

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AdminTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('License')),
                              DataColumn(label: Text('License Expiry')),
                              DataColumn(label: Text('Organization')),
                              DataColumn(label: Text('Vehicle')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: provider.drivers.map((driver) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(driver.name, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold))),
                                  DataCell(Text(driver.phone ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(Text(driver.lic ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(driver.licExp ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary)),
                                        if (driver.isLicenseExpired) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Expired', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        ] else if (driver.isLicenseExpiringSoon) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Expiring Soon', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        ]
                                      ],
                                    )
                                  ),
                                  DataCell(Text(driver.companyName ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(Text(driver.vehicle ?? 'N/A', style: const TextStyle(color: AdminTheme.textPrimary))),
                                  DataCell(
                                    Text(
                                      driver.status,
                                      style: TextStyle(
                                        color: _getStatusColor(driver.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: AdminTheme.primary),
                                      onPressed: () {
                                        context.go('/drivers/${driver.id}');
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ), // closes DataTable
                        ); // closes SingleChildScrollView
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Pagination
            const SizedBox(height: 16),
            Consumer<DriversProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${provider.totalDrivers}',
                      style: const TextStyle(color: AdminTheme.textSecondary),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AdminTheme.textPrimary),
                          onPressed: provider.currentPage > 1 ? provider.previousPage : null,
                        ),
                        Text(
                          'Page ${provider.currentPage} of ${provider.totalPages}',
                          style: const TextStyle(color: AdminTheme.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AdminTheme.textPrimary),
                          onPressed: provider.currentPage < provider.totalPages ? provider.nextPage : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownButtonContainer extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final String hint;

  const DropdownButtonContainer({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AdminTheme.surface,
          style: const TextStyle(color: AdminTheme.textPrimary),
          hint: Text(hint, style: const TextStyle(color: AdminTheme.textSecondary)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
