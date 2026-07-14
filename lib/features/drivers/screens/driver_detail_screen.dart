import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../providers/drivers_provider.dart';

class DriverDetailScreen extends StatefulWidget {
  final String id;

  const DriverDetailScreen({super.key, required this.id});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriversProvider>().fetchDriverDetail(widget.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showStatusUpdateDialog(BuildContext context, String currentStatus) {
    final remarksController = TextEditingController();
    final isSuspending = currentStatus == 'Active';
    final newStatus = isSuspending ? 'Suspended' : 'Active';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminTheme.surface,
          title: Text(isSuspending ? 'Suspend Driver' : 'Reactivate Driver', style: const TextStyle(color: AdminTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSuspending 
                  ? 'Are you sure you want to suspend this driver? They will be unable to accept new trips.'
                  : 'Are you sure you want to reactivate this driver?',
                style: const TextStyle(color: AdminTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Remarks / Reason',
                  labelStyle: TextStyle(color: AdminTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AdminTheme.border)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AdminTheme.primary)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isSuspending ? Colors.red : Colors.green),
              onPressed: () async {
                if (remarksController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remarks are required')));
                  return;
                }
                
                try {
                  await context.read<DriversProvider>().updateDriverStatus(widget.id, newStatus, remarksController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver status updated to $newStatus')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: Text(isSuspending ? 'Suspend' : 'Reactivate', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      appBar: AppBar(
        title: const Text('Driver Details'),
        backgroundColor: AdminTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/drivers'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AdminTheme.primary,
          unselectedLabelColor: AdminTheme.textSecondary,
          indicatorColor: AdminTheme.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Audit Logs'),
            Tab(text: 'Trips'),
          ],
        ),
      ),
      body: Consumer<DriversProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final driver = provider.currentDriverDetail;
          if (driver == null) {
            return const Center(child: Text('Driver not found', style: TextStyle(color: AdminTheme.textSecondary)));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showStatusUpdateDialog(context, driver.status),
                          icon: Icon(driver.status == 'Active' ? Icons.block : Icons.check_circle, color: Colors.white),
                          label: Text(driver.status == 'Active' ? 'Suspend Driver' : 'Reactivate Driver', style: const TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: driver.status == 'Active' ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (driver.isLicenseExpired)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text('WARNING: This driver\'s license has expired!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    else if (driver.isLicenseExpiringSoon)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('WARNING: This driver\'s license is expiring within 30 days!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                    Card(
                      color: AdminTheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Driver Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                            const Divider(color: AdminTheme.border),
                            _buildInfoRow('ID', driver.id),
                            _buildInfoRow('Phone', driver.phone ?? 'N/A'),
                            _buildInfoRow('Status', driver.status),
                            _buildInfoRow('Age', driver.age?.toString() ?? 'N/A'),
                            _buildInfoRow('Experience (Years)', driver.exp?.toString() ?? 'N/A'),
                            _buildInfoRow('Blood Group', driver.blood ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: AdminTheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('License Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                            const Divider(color: AdminTheme.border),
                            _buildInfoRow('License Number', driver.lic ?? 'N/A'),
                            _buildInfoRow('License Expiry', driver.licExp ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: AdminTheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Assignment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                            const Divider(color: AdminTheme.border),
                            _buildInfoRow('Organization', driver.companyName ?? 'N/A'),
                            _buildInfoRow('Fleet Owner', driver.ownerName ?? 'N/A'),
                            _buildInfoRow('Owner Email', driver.ownerEmail ?? 'N/A'),
                            _buildInfoRow('Assigned Vehicle', driver.vehicle ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Audit Logs Tab
              driver.auditLogs.isEmpty
                ? const Center(child: Text('No audit logs found', style: TextStyle(color: AdminTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: driver.auditLogs.length,
                    itemBuilder: (context, index) {
                      final log = driver.auditLogs[index];
                      return Card(
                        color: AdminTheme.surface,
                        child: ListTile(
                          title: Text(log['action'] ?? 'Action', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
                          subtitle: Text('Remarks: ${log['remarks'] ?? 'N/A'}\nDate: ${log['created_at'] ?? 'N/A'}', style: const TextStyle(color: AdminTheme.textSecondary)),
                        ),
                      );
                    },
                  ),
                  
              // Trips Tab
              driver.tripHistory == null || driver.tripHistory!.isEmpty
                ? const Center(child: Text('No trip history found', style: TextStyle(color: AdminTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: driver.tripHistory!.length,
                    itemBuilder: (context, index) {
                      final trip = driver.tripHistory![index];
                      return Card(
                        color: AdminTheme.surface,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AdminTheme.primary.withOpacity(0.1),
                            child: const Icon(Icons.route, color: AdminTheme.primary),
                          ),
                          title: Text('${trip['source_location'] ?? 'Unknown'} to ${trip['destination_location'] ?? 'Unknown'}', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold)),
                          subtitle: Text('Status: ${trip['status'] ?? 'N/A'}\nStart: ${trip['start_time'] ?? 'N/A'}', style: const TextStyle(color: AdminTheme.textSecondary)),
                        ),
                      );
                    },
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}
