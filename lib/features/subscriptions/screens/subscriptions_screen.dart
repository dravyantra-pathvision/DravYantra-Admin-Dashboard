import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../providers/subscriptions_provider.dart';
import '../models/subscription_models.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SubscriptionsProvider>();
      p.loadDashboard();
      p.loadPlans();
      p.loadSubscriptions(resetPage: true);
      p.loadInvoices(resetPage: true);
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subscriptions & Billing',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        final p = context.read<SubscriptionsProvider>();
                        p.loadDashboard();
                        p.loadPlans();
                        p.loadSubscriptions(resetPage: true);
                        p.loadInvoices(resetPage: true);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.card, foregroundColor: AdminTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AdminTheme.primary,
                indicatorWeight: 3,
                labelColor: AdminTheme.textPrimary,
                unselectedLabelColor: AdminTheme.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_outlined, size: 18)),
                  Tab(text: 'Plans', icon: Icon(Icons.workspace_premium_outlined, size: 18)),
                  Tab(text: 'Organizations', icon: Icon(Icons.business_outlined, size: 18)),
                  Tab(text: 'Invoices', icon: Icon(Icons.receipt_long_outlined, size: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _DashboardTab(),
                  _PlansTab(),
                  _OrganizationsTab(),
                  _InvoicesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1: DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionsProvider>(
      builder: (context, provider, _) {
        if (provider.isDashboardLoading) {
          return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
        }
        final stats = provider.dashboardStats;
        if (stats == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inbox_outlined, size: 48, color: AdminTheme.textMuted),
                const SizedBox(height: 12),
                Text(provider.error.isNotEmpty ? provider.error : 'No data available',
                    style: const TextStyle(color: AdminTheme.textSecondary)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _KpiCard(title: 'Active', value: '${stats.activeSubscriptions}', icon: Icons.check_circle, color: AdminTheme.success, subtitle: 'Subscriptions'),
                  _KpiCard(title: 'Trial', value: '${stats.trialSubscriptions}', icon: Icons.hourglass_top, color: AdminTheme.warning, subtitle: 'Organizations'),
                  _KpiCard(title: 'Suspended', value: '${stats.suspendedSubscriptions}', icon: Icons.pause_circle, color: AdminTheme.danger, subtitle: 'Organizations'),
                  _KpiCard(title: 'MRR', value: '₹${_formatNumber(stats.mrr)}', icon: Icons.trending_up, color: AdminTheme.primary, subtitle: 'Monthly Revenue'),
                  _KpiCard(title: 'Total Revenue', value: '₹${_formatNumber(stats.totalRevenue)}', icon: Icons.account_balance_wallet, color: AdminTheme.secondary, subtitle: 'All Time'),
                  _KpiCard(title: 'Pending', value: '₹${_formatNumber(stats.pendingRevenue)}', icon: Icons.pending_actions, color: AdminTheme.warning, subtitle: '${stats.pendingInvoices} invoices'),
                ],
              ),
              const SizedBox(height: 24),

              // Plan Distribution
              const Text('Plan Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: stats.planDistribution.map((pd) {
                  final colors = _planColor(pd.slug);
                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AdminTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(color: colors, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(pd.name, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${pd.count}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
                        Text('organizations', style: TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Recent Activity
              const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AdminTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: stats.recentActivity.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No recent activity', style: TextStyle(color: AdminTheme.textMuted))),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stats.recentActivity.length,
                        separatorBuilder: (_, __) => const Divider(color: AdminTheme.border, height: 1),
                        itemBuilder: (context, index) {
                          final a = stats.recentActivity[index];
                          return ListTile(
                            leading: _actionIcon(a.action),
                            title: Text(_formatAction(a.action), style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
                            subtitle: Text(a.orgName ?? 'Unknown org', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                            trailing: Text(
                              a.createdAt != null ? DateFormat('MMM d, HH:mm').format(a.createdAt!) : '',
                              style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2: PLANS
// ═══════════════════════════════════════════════════════════════════════════════

class _PlansTab extends StatelessWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionsProvider>(
      builder: (context, provider, _) {
        if (provider.isPlansLoading) {
          return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subscription Plans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
                  ElevatedButton.icon(
                    onPressed: () => _showPlanDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Plan'),
                    style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plan Cards Grid
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: provider.plans.map((plan) => _PlanCard(plan: plan)).toList(),
              ),

              if (provider.plans.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text('Feature Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
                const SizedBox(height: 12),
                _FeatureComparisonTable(plans: provider.plans),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = _planColor(plan.slug);
    final isEnterprise = plan.slug == 'enterprise';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEnterprise ? AdminTheme.primary.withOpacity(0.5) : AdminTheme.border, width: isEnterprise ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(plan.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
                    ),
                    if (isEnterprise)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Popular', style: TextStyle(color: AdminTheme.primaryLight, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: plan.displayPrice, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary)),
                      TextSpan(text: plan.displayBillingCycle, style: const TextStyle(fontSize: 14, color: AdminTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Limits
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _LimitRow(icon: Icons.directions_car, label: 'Vehicles', value: plan.maxVehicles > 99999 ? 'Unlimited' : '${plan.maxVehicles}'),
                _LimitRow(icon: Icons.person, label: 'Drivers', value: plan.maxDrivers > 99999 ? 'Unlimited' : '${plan.maxDrivers}'),
                _LimitRow(icon: Icons.cloud, label: 'Storage', value: plan.maxStorageGb > 99 ? 'Unlimited' : '${plan.maxStorageGb.toStringAsFixed(0)} GB'),
                const SizedBox(height: 12),
                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusChip(label: plan.isActive ? 'Active' : 'Inactive', color: plan.isActive ? AdminTheme.success : AdminTheme.danger),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: AdminTheme.textSecondary,
                          onPressed: () => _showPlanDialog(context, plan: plan),
                          tooltip: 'Edit',
                        ),
                        if (!isEnterprise)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: AdminTheme.danger,
                            onPressed: () => _confirmDeletePlan(context, plan),
                            tooltip: 'Delete',
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _LimitRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AdminTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _FeatureComparisonTable extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  const _FeatureComparisonTable({required this.plans});

  @override
  Widget build(BuildContext context) {
    // Collect all unique feature keys
    final allFeatures = <String, String>{};
    for (final plan in plans) {
      for (final f in plan.features) {
        allFeatures[f.featureKey] = f.featureLabel;
      }
    }

    if (allFeatures.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AdminTheme.surface),
          dataRowColor: WidgetStateProperty.all(AdminTheme.card),
          columns: [
            const DataColumn(label: Text('Feature', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
            ...plans.map((p) => DataColumn(
              label: Text(p.name, style: TextStyle(color: _planColor(p.slug), fontWeight: FontWeight.w600)),
            )),
          ],
          rows: allFeatures.entries.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry.value, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
              ...plans.map((p) {
                final feature = p.features.where((f) => f.featureKey == entry.key).firstOrNull;
                final enabled = feature?.isEnabled ?? false;
                return DataCell(
                  Icon(
                    enabled ? Icons.check_circle : Icons.cancel_outlined,
                    color: enabled ? AdminTheme.success : AdminTheme.textMuted,
                    size: 20,
                  ),
                );
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3: ORGANIZATIONS
// ═══════════════════════════════════════════════════════════════════════════════

class _OrganizationsTab extends StatelessWidget {
  const _OrganizationsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search organizations...',
                      hintStyle: const TextStyle(color: AdminTheme.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                      filled: true,
                      fillColor: AdminTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) => provider.setSubsSearch(val),
                  ),
                ),
                const SizedBox(width: 12),
                _FilterDropdown(
                  value: provider.statusFilter,
                  hint: 'Status',
                  items: const ['active', 'trial', 'suspended', 'expired', 'cancelled'],
                  onChanged: (val) => provider.setSubsFilter(status: val, search: provider.searchQuery),
                ),
                const SizedBox(width: 12),
                if (provider.statusFilter != null || (provider.searchQuery != null && provider.searchQuery!.isNotEmpty))
                  TextButton.icon(
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: provider.clearSubsFilters,
                    style: TextButton.styleFrom(foregroundColor: AdminTheme.textSecondary),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAssignPlanDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Assign Plan'),
                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: provider.isSubsLoading
                  ? const Center(child: CircularProgressIndicator(color: AdminTheme.primary))
                  : provider.subscriptions.isEmpty
                      ? const Center(child: Text('No subscriptions found', style: TextStyle(color: AdminTheme.textMuted)))
                      : Container(
                          decoration: BoxDecoration(
                            color: AdminTheme.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminTheme.border),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AdminTheme.surface),
                                columns: const [
                                  DataColumn(label: Text('Organization', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Plan', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Status', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Vehicles', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Drivers', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Renewal', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Expiry', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Actions', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                ],
                                rows: provider.subscriptions.map((sub) {
                                  return DataRow(cells: [
                                    DataCell(Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(sub.orgName ?? 'Unknown', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500)),
                                        Text(sub.orgEmail ?? '', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                                      ],
                                    )),
                                    DataCell(Text(sub.planName ?? '—', style: TextStyle(color: _planColor(sub.planSlug ?? ''), fontWeight: FontWeight.w600))),
                                    DataCell(_StatusChip(label: sub.status.toUpperCase(), color: _statusColor(sub.status))),
                                    DataCell(Text('${sub.actualVehicles ?? 0} / ${sub.maxVehicles ?? 0}',
                                        style: TextStyle(
                                          color: (sub.actualVehicles ?? 0) >= (sub.maxVehicles ?? 0) ? AdminTheme.danger : AdminTheme.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ))),
                                    DataCell(Text('${sub.actualDrivers ?? 0} / ${sub.maxDrivers ?? 0}',
                                        style: TextStyle(
                                          color: (sub.actualDrivers ?? 0) >= (sub.maxDrivers ?? 0) ? AdminTheme.danger : AdminTheme.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ))),
                                    DataCell(Text(
                                      sub.renewedAt != null ? DateFormat('MMM d, y').format(sub.renewedAt!) : '—',
                                      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                                    )),
                                    DataCell(Text(
                                      sub.currentPeriodEnd != null ? DateFormat('MMM d, y').format(sub.currentPeriodEnd!) : '—',
                                      style: TextStyle(
                                        color: sub.currentPeriodEnd != null && sub.currentPeriodEnd!.isBefore(DateTime.now())
                                            ? AdminTheme.danger
                                            : AdminTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    )),
                                    DataCell(_SubscriptionActions(sub: sub)),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            // Pagination
            _PaginationBar(
              currentPage: provider.currentPage,
              total: provider.totalSubscriptions,
              limit: provider.limit,
              onPrevious: provider.subsPreviousPage,
              onNext: provider.subsNextPage,
            ),
          ],
        );
      },
    );
  }
}

class _SubscriptionActions extends StatelessWidget {
  final OrganizationSubscription sub;
  const _SubscriptionActions({required this.sub});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SubscriptionsProvider>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AdminTheme.textSecondary, size: 20),
      color: AdminTheme.card,
      onSelected: (action) async {
        try {
          switch (action) {
            case 'activate':
              await provider.activateSubscription(sub.id);
              break;
            case 'suspend':
              final reason = await _showInputDialog(context, 'Suspend Subscription', 'Enter suspension reason');
              if (reason != null) await provider.suspendSubscription(sub.id, reason: reason);
              break;
            case 'renew':
              await provider.renewSubscription(sub.id);
              break;
            case 'extend_trial':
              final days = await _showInputDialog(context, 'Extend Trial', 'Extra days (default: 7)', defaultValue: '7');
              if (days != null) await provider.extendTrial(sub.id, extraDays: int.tryParse(days) ?? 7);
              break;
            case 'cancel':
              final reason = await _showInputDialog(context, 'Cancel Subscription', 'Enter cancellation reason');
              if (reason != null) await provider.cancelSubscription(sub.id, reason: reason);
              break;
            case 'invoice':
              await provider.generateInvoice(subscriptionId: sub.id, orgUid: sub.orgUid);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice generated'), backgroundColor: AdminTheme.success));
              break;
          }
          if (context.mounted && action != 'suspend' && action != 'cancel' && action != 'extend_trial') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action completed'), backgroundColor: AdminTheme.success));
          }
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.danger));
        }
      },
      itemBuilder: (_) {
        final items = <PopupMenuEntry<String>>[];
        if (sub.status == 'suspended' || sub.status == 'trial') {
          items.add(const PopupMenuItem(value: 'activate', child: _PopupItem(icon: Icons.check_circle, label: 'Activate', color: AdminTheme.success)));
        }
        if (sub.status == 'active' || sub.status == 'trial') {
          items.add(const PopupMenuItem(value: 'suspend', child: _PopupItem(icon: Icons.pause_circle, label: 'Suspend', color: AdminTheme.warning)));
        }
        if (sub.status != 'cancelled') {
          items.add(const PopupMenuItem(value: 'renew', child: _PopupItem(icon: Icons.autorenew, label: 'Renew', color: AdminTheme.info)));
        }
        if (sub.status == 'trial') {
          items.add(const PopupMenuItem(value: 'extend_trial', child: _PopupItem(icon: Icons.timer, label: 'Extend Trial', color: AdminTheme.secondary)));
        }
        if (sub.status != 'cancelled') {
          items.add(const PopupMenuItem(value: 'invoice', child: _PopupItem(icon: Icons.receipt, label: 'Generate Invoice', color: AdminTheme.primary)));
          items.add(const PopupMenuDivider());
          items.add(const PopupMenuItem(value: 'cancel', child: _PopupItem(icon: Icons.cancel, label: 'Cancel', color: AdminTheme.danger)));
        }
        return items;
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 4: INVOICES
// ═══════════════════════════════════════════════════════════════════════════════

class _InvoicesTab extends StatelessWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Filters
            Row(
              children: [
                _FilterDropdown(
                  value: provider.invoiceStatusFilter,
                  hint: 'Invoice Status',
                  items: const ['pending', 'paid', 'overdue', 'cancelled'],
                  onChanged: (val) => provider.setInvoiceFilter(val),
                ),
                const SizedBox(width: 12),
                if (provider.invoiceStatusFilter != null)
                  TextButton.icon(
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: () => provider.setInvoiceFilter(null),
                    style: TextButton.styleFrom(foregroundColor: AdminTheme.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Invoice Table
            Expanded(
              child: provider.isInvoicesLoading
                  ? const Center(child: CircularProgressIndicator(color: AdminTheme.primary))
                  : provider.invoices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: AdminTheme.textMuted),
                              const SizedBox(height: 12),
                              const Text('No invoices found', style: TextStyle(color: AdminTheme.textMuted)),
                              const SizedBox(height: 4),
                              const Text('Generate invoices from the Organizations tab', style: TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AdminTheme.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminTheme.border),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AdminTheme.surface),
                                columns: const [
                                  DataColumn(label: Text('Invoice #', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Organization', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Plan', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Amount', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Tax', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Total', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Status', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Due Date', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                  DataColumn(label: Text('Actions', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600))),
                                ],
                                rows: provider.invoices.map((inv) {
                                  final isOverdue = inv.status == 'pending' && inv.dueDate != null && inv.dueDate!.isBefore(DateTime.now());
                                  return DataRow(cells: [
                                    DataCell(Text(inv.invoiceNumber, style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w600, fontSize: 13))),
                                    DataCell(Text(inv.orgName ?? '—', style: const TextStyle(color: AdminTheme.textPrimary))),
                                    DataCell(Text(inv.planName ?? '—', style: const TextStyle(color: AdminTheme.textSecondary))),
                                    DataCell(Text('₹${inv.amount.toStringAsFixed(2)}', style: const TextStyle(color: AdminTheme.textPrimary))),
                                    DataCell(Text('₹${inv.taxAmount.toStringAsFixed(2)}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
                                    DataCell(Text('₹${inv.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w700))),
                                    DataCell(_StatusChip(
                                      label: isOverdue ? 'OVERDUE' : inv.status.toUpperCase(),
                                      color: isOverdue ? AdminTheme.danger : _invoiceStatusColor(inv.status),
                                    )),
                                    DataCell(Text(
                                      inv.dueDate != null ? DateFormat('MMM d, y').format(inv.dueDate!) : '—',
                                      style: TextStyle(color: isOverdue ? AdminTheme.danger : AdminTheme.textSecondary, fontSize: 13),
                                    )),
                                    DataCell(
                                      inv.status == 'pending'
                                          ? TextButton.icon(
                                              icon: const Icon(Icons.check, size: 16),
                                              label: const Text('Mark Paid'),
                                              style: TextButton.styleFrom(foregroundColor: AdminTheme.success),
                                              onPressed: () async {
                                                try {
                                                  await provider.markInvoicePaid(inv.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice marked as paid'), backgroundColor: AdminTheme.success));
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.danger));
                                                }
                                              },
                                            )
                                          : inv.status == 'paid'
                                              ? Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.check_circle, size: 16, color: AdminTheme.success),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      inv.paidAt != null ? DateFormat('MMM d').format(inv.paidAt!) : 'Paid',
                                                      style: const TextStyle(color: AdminTheme.success, fontSize: 12),
                                                    ),
                                                  ],
                                                )
                                              : const Text('—', style: TextStyle(color: AdminTheme.textMuted)),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}

class _PopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PopupItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
          dropdownColor: AdminTheme.card,
          style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text('All $hint', style: const TextStyle(color: AdminTheme.textSecondary))),
            ...items.map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int total;
  final int limit;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationBar({required this.currentPage, required this.total, required this.limit, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final totalPages = (total / limit).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$total total', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? onPrevious : null,
          color: AdminTheme.textSecondary,
        ),
        Text('$currentPage / ${totalPages > 0 ? totalPages : 1}', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: (currentPage * limit) < total ? onNext : null,
          color: AdminTheme.textSecondary,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIALOGS
// ═══════════════════════════════════════════════════════════════════════════════

Future<String?> _showInputDialog(BuildContext context, String title, String hint, {String? defaultValue}) async {
  final controller = TextEditingController(text: defaultValue);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AdminTheme.card,
      title: Text(title, style: const TextStyle(color: AdminTheme.textPrimary)),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: AdminTheme.textPrimary),
        decoration: InputDecoration(hintText: hint),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Confirm')),
      ],
    ),
  );
}

void _showPlanDialog(BuildContext context, {SubscriptionPlan? plan}) {
  final isEditing = plan != null;
  final nameCtrl = TextEditingController(text: plan?.name ?? '');
  final slugCtrl = TextEditingController(text: plan?.slug ?? '');
  final descCtrl = TextEditingController(text: plan?.description ?? '');
  final priceCtrl = TextEditingController(text: plan?.price.toStringAsFixed(0) ?? '0');
  final vehiclesCtrl = TextEditingController(text: plan?.maxVehicles.toString() ?? '10');
  final driversCtrl = TextEditingController(text: plan?.maxDrivers.toString() ?? '10');
  final storageCtrl = TextEditingController(text: plan?.maxStorageGb.toStringAsFixed(0) ?? '5');
  final trialCtrl = TextEditingController(text: plan?.trialDays.toString() ?? '0');
  String planType = plan?.planType ?? 'paid';
  String billingCycle = plan?.billingCycle ?? 'monthly';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: AdminTheme.card,
        title: Text(isEditing ? 'Edit Plan' : 'Create Plan', style: const TextStyle(color: AdminTheme.textPrimary)),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Plan Name')),
                const SizedBox(height: 12),
                TextField(controller: slugCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Slug (URL-safe)')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: planType,
                        decoration: const InputDecoration(labelText: 'Plan Type'),
                        dropdownColor: AdminTheme.card,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'trial', child: Text('Trial')),
                          DropdownMenuItem(value: 'paid', child: Text('Paid')),
                          DropdownMenuItem(value: 'custom', child: Text('Custom')),
                        ],
                        onChanged: (v) => setDialogState(() => planType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: billingCycle,
                        decoration: const InputDecoration(labelText: 'Billing Cycle'),
                        dropdownColor: AdminTheme.card,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('None')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'annual', child: Text('Annual')),
                        ],
                        onChanged: (v) => setDialogState(() => billingCycle = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: priceCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: trialCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Trial Days'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: vehiclesCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Max Vehicles'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: driversCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Max Drivers'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: storageCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Max Storage (GB)'), keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'name': nameCtrl.text,
                'slug': slugCtrl.text,
                'description': descCtrl.text,
                'plan_type': planType,
                'billing_cycle': billingCycle,
                'price': double.tryParse(priceCtrl.text) ?? 0,
                'trial_days': int.tryParse(trialCtrl.text) ?? 0,
                'max_vehicles': int.tryParse(vehiclesCtrl.text) ?? 0,
                'max_drivers': int.tryParse(driversCtrl.text) ?? 0,
                'max_storage_gb': double.tryParse(storageCtrl.text) ?? 1,
              };
              try {
                final provider = context.read<SubscriptionsProvider>();
                if (isEditing) {
                  await provider.updatePlan(plan!.id, body);
                } else {
                  await provider.createPlan(body);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.danger));
              }
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    ),
  );
}

void _confirmDeletePlan(BuildContext context, SubscriptionPlan plan) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AdminTheme.card,
      title: const Text('Delete Plan', style: TextStyle(color: AdminTheme.textPrimary)),
      content: Text('Are you sure you want to delete "${plan.name}"? This cannot be undone.', style: const TextStyle(color: AdminTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
          onPressed: () async {
            try {
              await context.read<SubscriptionsProvider>().deletePlan(plan.id);
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.danger));
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void _showAssignPlanDialog(BuildContext context) {
  final orgUidCtrl = TextEditingController();
  int? selectedPlanId;
  final notesCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      final plans = context.read<SubscriptionsProvider>().plans;
      return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AdminTheme.card,
          title: const Text('Assign Plan to Organization', style: TextStyle(color: AdminTheme.textPrimary)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orgUidCtrl,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Organization UID', hintText: 'Enter the fleet owner UID'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedPlanId,
                  decoration: const InputDecoration(labelText: 'Select Plan'),
                  dropdownColor: AdminTheme.card,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  items: plans.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} — ${p.displayPrice}'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedPlanId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (orgUidCtrl.text.isEmpty || selectedPlanId == null) return;
                try {
                  await context.read<SubscriptionsProvider>().assignPlan(
                    orgUid: orgUidCtrl.text,
                    planId: selectedPlanId!,
                    notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan assigned successfully'), backgroundColor: AdminTheme.success));
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.danger));
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

String _formatNumber(double n) {
  if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toStringAsFixed(0);
}

Color _planColor(String slug) {
  switch (slug) {
    case 'free-trial':   return const Color(0xFF06B6D4); // Cyan
    case 'starter':      return const Color(0xFF10B981); // Emerald
    case 'professional': return const Color(0xFF6366F1); // Indigo
    case 'enterprise':   return const Color(0xFFF59E0B); // Amber
    default:             return AdminTheme.textSecondary;
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':    return AdminTheme.success;
    case 'trial':     return AdminTheme.secondary;
    case 'suspended': return AdminTheme.warning;
    case 'expired':   return AdminTheme.danger;
    case 'cancelled': return AdminTheme.textMuted;
    default:          return AdminTheme.textSecondary;
  }
}

Color _invoiceStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':      return AdminTheme.success;
    case 'pending':   return AdminTheme.warning;
    case 'overdue':   return AdminTheme.danger;
    case 'cancelled': return AdminTheme.textMuted;
    default:          return AdminTheme.textSecondary;
  }
}

Widget _actionIcon(String action) {
  switch (action) {
    case 'plan_assigned':    return const Icon(Icons.assignment_turned_in, color: AdminTheme.success, size: 20);
    case 'activated':        return const Icon(Icons.check_circle, color: AdminTheme.success, size: 20);
    case 'suspended':        return const Icon(Icons.pause_circle, color: AdminTheme.warning, size: 20);
    case 'renewed':          return const Icon(Icons.autorenew, color: AdminTheme.info, size: 20);
    case 'trial_extended':   return const Icon(Icons.timer, color: AdminTheme.secondary, size: 20);
    case 'cancelled':        return const Icon(Icons.cancel, color: AdminTheme.danger, size: 20);
    case 'invoice_generated':return const Icon(Icons.receipt, color: AdminTheme.primary, size: 20);
    case 'invoice_paid':     return const Icon(Icons.payment, color: AdminTheme.success, size: 20);
    default:                 return const Icon(Icons.info, color: AdminTheme.textMuted, size: 20);
  }
}

String _formatAction(String action) {
  return action.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
}
