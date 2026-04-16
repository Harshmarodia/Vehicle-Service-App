import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../shell/admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '', password = '';
  bool isLoading = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);
    final success = await ApiService.login(username, password);
    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Admin Credentials"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)]),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFFFFD700), size: 60),
                const SizedBox(height: 20),
                const Text("Admin Portal", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("Secure access for MotoBuddy management."),
                const SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Admin Email / Username", prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                  onSaved: (v) => username = v!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                  onSaved: (v) => password = v!,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading ? const CircularProgressIndicator(color: Color(0xFFFFD700)) : const Text("Access Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
