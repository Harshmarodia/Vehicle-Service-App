import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Import to access themeNotifier
import '../../core/services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = "English (US)";
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? "English (US)";
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = themeNotifier.value == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await prefs.setString('theme', themeNotifier.value == ThemeMode.dark ? 'dark' : 'light');
    setState(() {});
  }

  Future<void> _updateLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _selectedLanguage = lang);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English (US)"),
              onTap: () {
                _updateLanguage("English (US)");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Hindi (India)"),
              onTap: () {
                _updateLanguage("Hindi (India)");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    bool isChanging = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldController,
                decoration: const InputDecoration(labelText: "Current Password"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isChanging ? null : () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: isChanging ? null : () async {
                if (oldController.text.isEmpty || newController.text.isEmpty) return;
                
                setDialogState(() => isChanging = true);
                final userId = await ApiService.getUserId();
                final res = await ApiService.changePassword(
                  userId: userId ?? "",
                  oldPassword: oldController.text,
                  newPassword: newController.text,
                );
                
                if (context.mounted) {
                  setDialogState(() => isChanging = false);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res["message"] ?? "Action completed"),
                      backgroundColor: res["success"] == true ? Colors.green : Colors.red,
                    )
                  );
                }
              }, 
              child: isChanging 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Update")
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        title: Text("App Settings", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsSection("Preferences", isDarkMode),
          _buildSettingsTile(
            Icons.notifications_none_rounded, 
            "Notifications", 
            "Manage your alerts",
            isDarkMode: isDarkMode,
            onTap: () {},
          ),
          _buildSettingsTile(
            Icons.language_rounded, 
            "Language", 
            _selectedLanguage,
            isDarkMode: isDarkMode,
            onTap: _showLanguageDialog,
          ),
          _buildSettingsTile(
            Icons.dark_mode_outlined, 
            "Dark Mode", 
            isDarkMode ? "On" : "Off",
            isDarkMode: isDarkMode,
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) => _toggleTheme(),
              activeColor: Colors.yellow,
            ),
            onTap: _toggleTheme,
          ),
          
          const SizedBox(height: 30),
          _buildSettingsSection("Security", isDarkMode),
          _buildSettingsTile(
            Icons.lock_outline_rounded, 
            "Change Password", 
            "Keep your account secure",
            isDarkMode: isDarkMode,
            onTap: _showChangePasswordDialog,
          ),
          
          const SizedBox(height: 30),
          _buildSettingsSection("Data & Privacy", isDarkMode),
          _buildSettingsTile(
            Icons.privacy_tip_outlined, 
            "Privacy Policy", 
            "Read our terms",
            isDarkMode: isDarkMode,
            onTap: () {},
          ),
          _buildSettingsTile(
            Icons.delete_forever_outlined, 
            "Delete Account", 
            "Careful, this is permanent", 
            isDestructive: true,
            isDarkMode: isDarkMode,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 14),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon, 
    String title, 
    String subtitle, 
    {bool isDestructive = false, required bool isDarkMode, Widget? trailing, VoidCallback? onTap}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : (isDarkMode ? Colors.yellow : Colors.black87)),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            color: isDestructive ? Colors.red : (isDarkMode ? Colors.white : Colors.black87)
          )
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white60 : Colors.black54)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}
