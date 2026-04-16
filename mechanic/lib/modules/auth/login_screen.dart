import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter both email and password");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.mechanicLogin(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _errorMessage = result['message'] ?? "Login failed");
      }
    } catch (e) {
      setState(() => _errorMessage = "An unexpected error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.engineering, size: 48, color: AppTheme.darkHeaderColor),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "Mechanic Hub",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkHeaderColor,
                        ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Sign in to your dashboard",
                    style: TextStyle(color: Colors.grey.shade600),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ).animate().fadeIn().shake(),
                const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 24),
                const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                        : const Text("Sign In"),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Don't have an account? Register Now"),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 800.ms),
      ),
    );
  }
}
