import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/constants.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: AppConstants.sidebarWidth,
      decoration: const BoxDecoration(
        color: Colors.white, // Clean White Sidebar matching user reference image
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Brand Logo Header (Matching reference logo style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.grid_view_rounded, color: Color(0xFF0284C7), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'DravYantra',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items List (No category headers, flat clean layout matching reference)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _SidebarItem(icon: Icons.dashboard_outlined, title: 'Dashboard', route: '/dashboard', currentRoute: location),
                _SidebarItem(icon: Icons.business_outlined, title: 'Organizations', route: '/organizations', currentRoute: location),
                _SidebarItem(icon: Icons.people_outline_rounded, title: 'Fleet Owners', route: '/fleet-owners', currentRoute: location),
                _SidebarItem(icon: Icons.directions_car_outlined, title: 'Vehicles', route: '/vehicles', currentRoute: location),
                _SidebarItem(icon: Icons.person_outline_rounded, title: 'Drivers', route: '/drivers', currentRoute: location),
                _SidebarItem(icon: Icons.alt_route_rounded, title: 'Trips', route: '/trips', currentRoute: location),
                _SidebarItem(icon: Icons.devices_other_rounded, title: 'Devices', route: '/devices', currentRoute: location),
                _SidebarItem(icon: Icons.map_outlined, title: 'Live Fleet', route: '/live', currentRoute: location),
                _SidebarItem(icon: Icons.notifications_none_rounded, title: 'Alerts', route: '/alerts', currentRoute: location),
                _SidebarItem(icon: Icons.analytics_outlined, title: 'Analytics', route: '/analytics', currentRoute: location),
                _SidebarItem(icon: Icons.assessment_outlined, title: 'Reports', route: '/reports', currentRoute: location),
                _SidebarItem(icon: Icons.history_rounded, title: 'Activity Logs', route: '/audit', currentRoute: location),
                _SidebarItem(icon: Icons.card_membership_outlined, title: 'Subscriptions', route: '/subscriptions', currentRoute: location),
                _SidebarItem(icon: Icons.headset_mic_outlined, title: 'Support & Tickets', route: '/support', currentRoute: location),
                _SidebarItem(icon: Icons.person_outline, title: 'Profile', route: '/profile', currentRoute: location),
                _SidebarItem(icon: Icons.settings_outlined, title: 'Settings', route: '/settings', currentRoute: location),
              ],
            ),
          ),

          // Footer Version Tag
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Admin Panel v1.0.0',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // Soft blue active pill background (Matching user reference image 1)
              color: isActive ? const Color(0xFFE0F2FE) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF0284C7) : const Color(0xFF334155),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: isActive ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
