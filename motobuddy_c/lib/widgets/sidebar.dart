import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/service_booking_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/history/service_history_screen.dart';
import '../screens/profile/vehicle_management_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../core/services/api_service.dart';
import '../screens/web/landing/landing_page.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const Sidebar({super.key, required this.isCollapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 260,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildGroupLabel("MAIN"),
                _buildMenuItem(context, "Dashboard", Icons.dashboard_outlined, const LandingPage()), // Use landing or home as dashboard
                _buildMenuItem(context, "Request Help", Icons.emergency_share_outlined, const ServiceBookingScreen(), isEmergency: true),
                
                _buildGroupLabel("SERVICES"),
                _buildMenuItem(context, "Shop / Products", Icons.shopping_bag_outlined, const ShopScreen()),
                _buildMenuItem(context, "Request History", Icons.history_outlined, const ServiceHistoryScreen()),
                _buildMenuItem(context, "My Vehicles", Icons.directions_car_outlined, const VehicleManagementScreen()),
                
                _buildGroupLabel("SUPPORT"),
                _buildMenuItem(context, "Support / Complaints", Icons.support_agent_outlined, const SupportScreen()),
                
                _buildGroupLabel("ACCOUNT"),
                _buildMenuItem(context, "Profile", Icons.person_outline, const ProfileScreen()),
                _buildMenuItem(context, "Logout", Icons.logout, null, isLogout: true),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width >= 1024)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(isCollapsed ? Icons.chevron_right : Icons.chevron_left),
                onPressed: onToggle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.motorcycle, color: Colors.blue, size: 30),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Text(
              "MotoBuddy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupLabel(String label) {
    if (isCollapsed) return const Divider();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget? target, {bool isEmergency = false, bool isLogout = false}) {
    final color = isEmergency ? Colors.orange.shade700 : Colors.black87;
    
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: isCollapsed ? null : Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isEmergency ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: () async {
        if (isLogout) {
          await ApiService.logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (r) => false);
          }
          return;
        }
        if (target != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => target));
        }
      },
      contentPadding: EdgeInsets.symmetric(horizontal: isCollapsed ? 28 : 24),
      visualDensity: VisualDensity.compact,
    );
  }
}
