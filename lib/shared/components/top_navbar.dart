import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/theme_provider.dart';
import '../../features/authentication/providers/auth_provider.dart';
import '../../features/profile/providers/profile_provider.dart';

class TopNavbar extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const TopNavbar({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().user;
    final profile = context.watch<ProfileProvider>().profile;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final displayName = profile?.fullName ?? authUser?.fullName ?? 'Admin User';

    final navBg   = isDark ? AdminTheme.darkSurface    : AdminTheme.surface;
    final navBorder= isDark ? AdminTheme.darkBorder     : AdminTheme.border;
    final textPri  = isDark ? AdminTheme.darkTextPrimary: AdminTheme.textPrimary;
    final textSec  = isDark ? AdminTheme.darkTextSecondary : AdminTheme.textSecondary;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: navBg,
        border: Border(bottom: BorderSide(color: navBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Hamburger menu for mobile/tablet
          if (onMenuPressed != null)
            IconButton(
              icon: Icon(Icons.menu, color: textPri),
              onPressed: onMenuPressed,
            )
          else
            const SizedBox.shrink(),

          // Right side - Theme toggle + Profile & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 🌙 Moon / ☀️ Sun theme toggle
              Tooltip(
                message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                child: InkWell(
                  onTap: () => themeProvider.toggleTheme(),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: isDark
                          ? AdminTheme.primary.withOpacity(0.85)
                          : AdminTheme.border,
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFF6366F1) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textSec),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(displayName, style: TextStyle(fontWeight: FontWeight.w600, color: textPri)),
                  Text(authUser?.email ?? 'admin@dravyantra.com', style: TextStyle(fontSize: 12, color: textSec)),
                ],
              ),
              const SizedBox(width: 16),
              PopupMenuButton(
                icon: const CircleAvatar(backgroundColor: AdminTheme.primary, child: Icon(Icons.person, color: Colors.white, size: 20)),
                color: isDark ? AdminTheme.darkCard : AdminTheme.card,
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
