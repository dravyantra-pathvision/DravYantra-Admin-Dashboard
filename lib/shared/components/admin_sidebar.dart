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
        color: Color(0xFF0F172A), // Dark Slate Navy Sidebar matching Fleet Owner App
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping, color: Color(0xFF3B82F6)),
              SizedBox(width: 12),
              Text('DravYantra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarItem(icon: Icons.dashboard_rounded, title: 'Dashboard', route: '/dashboard', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Management'),
                _SidebarItem(icon: Icons.business_rounded, title: 'Organizations', route: '/organizations', currentRoute: location),
                _SidebarItem(icon: Icons.groups_rounded, title: 'Fleet Owners', route: '/fleet-owners', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Fleet Operations'),
                _SidebarItem(icon: Icons.directions_car_rounded, title: 'Vehicles', route: '/vehicles', currentRoute: location),
                _SidebarItem(icon: Icons.person_pin_rounded, title: 'Drivers', route: '/drivers', currentRoute: location),
                _SidebarItem(icon: Icons.route_rounded, title: 'Trips', route: '/trips', currentRoute: location),
                _SidebarItem(icon: Icons.devices_rounded, title: 'Devices', route: '/devices', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Monitoring'),
                _SidebarItem(icon: Icons.map_rounded, title: 'Live Fleet', route: '/live', currentRoute: location),
                _SidebarItem(icon: Icons.warning_rounded, title: 'Alerts', route: '/alerts', currentRoute: location),
                _SidebarItem(icon: Icons.analytics_rounded, title: 'Analytics', route: '/analytics', currentRoute: location),
                _SidebarItem(icon: Icons.insert_chart_rounded, title: 'Reports', route: '/reports', currentRoute: location),
                
                const _SidebarSectionTitle(title: 'Administration'),
                _SidebarItem(icon: Icons.history_rounded, title: 'Activity Logs', route: '/audit', currentRoute: location),
                _SidebarItem(icon: Icons.settings_rounded, title: 'Settings', route: '/settings', currentRoute: location),
                _SidebarItem(icon: Icons.card_membership_rounded, title: 'Subscriptions', route: '/subscriptions', currentRoute: location),
                _SidebarItem(icon: Icons.headset_mic_rounded, title: 'Support & Tickets', route: '/support', currentRoute: location),
                _SidebarItem(icon: Icons.account_circle_rounded, title: 'Profile', route: '/profile', currentRoute: location),

              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Admin Panel v1.0.0', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
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
          color: Color(0xFF64748B),
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
              color: isActive ? AdminTheme.primary : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? Colors.white : const Color(0xFF94A3B8), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFFCBD5E1),
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
