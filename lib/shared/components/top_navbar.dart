import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../features/authentication/providers/auth_provider.dart';
import '../../features/profile/providers/profile_provider.dart';

class TopNavbar extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const TopNavbar({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().user;
    final profile = context.watch<ProfileProvider>().profile;
    final displayName = profile?.fullName ?? authUser?.fullName ?? 'Admin User';
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminTheme.surface,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Hamburger menu for mobile/tablet
          if (onMenuPressed != null)
            IconButton(
              icon: const Icon(Icons.menu, color: AdminTheme.textPrimary),
              onPressed: onMenuPressed,
            )
          else
            const SizedBox.shrink(),
          
          // Right side - Profile & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AdminTheme.textSecondary),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
                  Text(authUser?.email ?? 'admin@dravyantra.com', style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary)),
                ],
              ),
              const SizedBox(width: 16),
              PopupMenuButton(
                icon: const CircleAvatar(backgroundColor: AdminTheme.primary, child: Icon(Icons.person, color: Colors.white, size: 20)),
                color: AdminTheme.card,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(children: [Icon(Icons.logout, color: AdminTheme.danger, size: 20), SizedBox(width: 8), Text('Logout', style: TextStyle(color: AdminTheme.danger))]),
                    onTap: () {
                      context.read<AuthProvider>().logout();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
