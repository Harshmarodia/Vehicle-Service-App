import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../history/service_history_screen.dart';
import '../payment/payment_screen.dart';
import '../web/content/video_content_screen.dart';
import 'addresses_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final result = await ApiService.getUserProfile();
    if (mounted) {
      setState(() {
        userData = result['user'];
        isLoading = false;
        nameController.text = userData?['name'] ?? "";
        phoneController.text = userData?['phone'] ?? "";
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isLoading = true);
    final result = await ApiService.updateProfile(
      name: nameController.text,
      phone: phoneController.text,
    );
    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        setState(() {
          isEditing = false;
        });
        _fetchUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update profile")));
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.yellow.shade100,
                  child: const Icon(Icons.person, size: 60, color: Colors.yellow),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 18,
                    child: IconButton(
                      icon: Icon(isEditing ? Icons.check : Icons.edit, size: 14, color: Colors.white),
                      onPressed: () {
                        if (isEditing) {
                          _updateProfile();
                        } else {
                          setState(() {
                            isEditing = true;
                            nameController.text = userData?['name'] ?? "";
                            phoneController.text = userData?['phone'] ?? "";
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isEditing) ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => isEditing = false),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ] else ...[
              Text(
                userData?['name'] ?? "MotoBuddy User",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                userData?['email'] ?? "email@example.com",
                style: const TextStyle(color: Colors.black45),
              ),
            ],
            const SizedBox(height: 40),
            _ProfileOption(
              icon: Icons.history_rounded, 
              title: "Booking History", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceHistoryScreen())),
            ),
            _ProfileOption(
              icon: Icons.location_on_outlined, 
              title: "Saved Addresses", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())),
            ),
            _ProfileOption(
              icon: Icons.settings_outlined, 
              title: "App Settings", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _ProfileOption(
              icon: Icons.help_outline_rounded, 
              title: "Help & Support", 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VideoContentScreen(
                      category: "MotoBuddy 24/7 Support", 
                      content: [
                        {"title": "Customer Hotline", "description": "Call us anytime for emergency assistance.", "contact": "+1-800-MOTO-HELP"},
                        {"title": "WhatsApp Support", "description": "Quick chat for service updates and queries.", "contact": "+1-987-654-3210"},
                        {"title": "Email Desk", "description": "Detailed support for accounts and technical issues.", "contact": "support@motobuddy.com"},
                      ],
                      backgroundImage: "https://images.unsplash.com/photo-1534536281715-e28d76689b4d?auto=format&fit=crop&w=1200&q=80",
                      isSupport: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  await ApiService.logout();
                  if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ProfileOption({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 22),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}