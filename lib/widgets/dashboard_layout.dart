import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  bool isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 1024;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? Sidebar(isCollapsed: false, onToggle: () {}) : null,
      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              isCollapsed: isSidebarCollapsed,
              onToggle: () => setState(() => isSidebarCollapsed = !isSidebarCollapsed),
            ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  onMenuPressed: isMobile ? () => _scaffoldKey.currentState?.openDrawer() : null,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
