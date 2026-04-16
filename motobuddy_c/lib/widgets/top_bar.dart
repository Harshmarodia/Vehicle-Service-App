import 'package:flutter/material.dart';
import '../screens/profile/profile_screen.dart';
import '../core/services/api_service.dart';
import '../screens/web/landing/landing_page.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  const TopBar({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SizedBox(
                  width: 500,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search services, mechanics...",
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF1F3F4),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == "Logout") {
                await ApiService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (r) => false);
                }
              } else if (val == "Profile") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }
            },
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              const PopupMenuItem(value: "Profile", child: Text("Profile")),
              const PopupMenuItem(value: "Settings", child: Text("Settings")),
              const PopupMenuDivider(),
              const PopupMenuItem(value: "Logout", child: Text("Logout", style: TextStyle(color: Colors.red))),
            ],
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
