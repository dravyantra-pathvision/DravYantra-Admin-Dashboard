import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'top_navbar.dart';
import '../../app/theme.dart';

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
