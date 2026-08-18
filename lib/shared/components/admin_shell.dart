import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_sidebar.dart';
import 'top_navbar.dart';
import '../../app/theme.dart';
import '../../features/authentication/providers/auth_provider.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        
        return Scaffold(
          drawer: !isDesktop ? const Drawer(child: AdminSidebar()) : null,
          body: Row(
            children: [
              if (isDesktop) const AdminSidebar(),
              Expanded(
                child: Column(
                  children: [
                    Builder(
                      builder: (innerContext) => TopNavbar(
                        onMenuPressed: !isDesktop 
                          ? () => Scaffold.of(innerContext).openDrawer() 
                          : null,
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (!auth.isOfflineMode) return const SizedBox.shrink();
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.amber.shade900,
                          child: const Row(
                            children: [
                              Icon(Icons.wifi_off, color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '⚠️ Admin Panel Operating in Offline Mode: AWS Backend server unreachable. Real-time platform sync is offline.',
                                  style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        color: AdminTheme.background,
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
