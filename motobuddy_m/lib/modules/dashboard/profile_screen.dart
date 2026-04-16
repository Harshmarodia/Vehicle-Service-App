import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final id = await ApiService.getMechanicId();
    if (id != null) {
      final result = await ApiService.getMechanicProfile(id);
      if (mounted) {
        setState(() {
          _profile = result['success'] == true ? result['profile'] : null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkHeaderColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text("Failed to load profile"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(Icons.engineering, size: 60, color: AppTheme.darkHeaderColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _profile!['name'] ?? 'Mechanic',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "MotoBuddy Certified Mechanic",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      _buildInfoCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, "Email", _profile!['email'] ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone_outlined, "Phone", _profile!['phone'] ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow(Icons.work_outline, "Expertise", _profile!['expertise'] ?? 'General Mechanic'),
          const Divider(height: 32),
          _buildInfoRow(Icons.history_edu_outlined, "Experience", _profile!['experience']?.toString() ?? '3+ Years'),
          const Divider(height: 32),
          _buildInfoRow(Icons.star_outline, "Rating", "${_profile!['rating'] ?? '5.0'} ★"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
