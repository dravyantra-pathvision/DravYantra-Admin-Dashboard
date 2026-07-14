import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../app/constants.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Container(
      width: AppConstants.sidebarWidth,
      decoration: const BoxDecoration(
        gradient: AdminTheme.sidebarGradient,
        border: Border(right: BorderSide(color: AdminTheme.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping, color: AdminTheme.primary),
              SizedBox(width: 12),
              Text('DravYantra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarItem(icon: Icons.dashboard, title: 'Dashboard', route: '/dashboard', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Management'),
                _SidebarItem(icon: Icons.business, title: 'Organizations', route: '/organizations', currentRoute: location),
                _SidebarItem(icon: Icons.groups, title: 'Fleet Owners', route: '/fleet-owners', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Fleet Operations'),
                _SidebarItem(icon: Icons.directions_car, title: 'Vehicles', route: '/vehicles', currentRoute: location),
                _SidebarItem(icon: Icons.person_pin, title: 'Drivers', route: '/drivers', currentRoute: location),
                _SidebarItem(icon: Icons.route, title: 'Trips', route: '/trips', currentRoute: location),
                _SidebarItem(icon: Icons.devices, title: 'Devices', route: '/devices', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Monitoring'),
                _SidebarItem(icon: Icons.map, title: 'Live Fleet', route: '/live', currentRoute: location),
                _SidebarItem(icon: Icons.warning, title: 'Alerts', route: '/alerts', currentRoute: location),
                _SidebarItem(icon: Icons.analytics, title: 'Analytics', route: '/analytics', currentRoute: location),
                _SidebarItem(icon: Icons.insert_chart, title: 'Reports', route: '/reports', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Administration'),
                _SidebarItem(icon: Icons.history, title: 'Activity Logs', route: '/audit', currentRoute: location),
                _SidebarItem(icon: Icons.settings, title: 'Settings', route: '/settings', currentRoute: location),
                _SidebarItem(icon: Icons.card_membership, title: 'Subscriptions', route: '/subscriptions', currentRoute: location),
                _SidebarItem(icon: Icons.headset_mic, title: 'Support & Tickets', route: '/support', currentRoute: location),
                _SidebarItem(icon: Icons.account_circle, title: 'Profile', route: '/profile', currentRoute: location),

              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Admin Panel v1.0.0', style: TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionTitle extends StatelessWidget {
  final String title;
  const _SidebarSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AdminTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route || (route != '/dashboard' && currentRoute.startsWith(route));
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? AdminTheme.sidebarActive : Colors.transparent,
              border: Border.all(color: isActive ? AdminTheme.border : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? AdminTheme.primaryLight : AdminTheme.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? AdminTheme.textPrimary : AdminTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
