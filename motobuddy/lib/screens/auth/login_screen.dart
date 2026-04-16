import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../screens/booking/service_booking_screen.dart';
import '../../core/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  bool _isLoading = false;
  
  // Captcha Logic
  late int num1, num2, captchaAnswer;
  

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
    _generateCaptcha();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    setState(() {
      num1 = 1 + (DateTime.now().millisecond % 9);
      num2 = 1 + (DateTime.now().microsecond % 9);
      captchaAnswer = num1 + num2;
      _captchaController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _checkSession() async {
    bool logged = await ApiService.isLoggedIn();
    if (!mounted) return;

    if (logged) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ServiceBookingScreen()),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email) && 
        !RegExp(r"^[6-9]\d{9}$").hasMatch(email)) {
      _showError("Enter a valid Email or 10-digit Indian Phone Number");
      return;
    }

    if (int.tryParse(_captchaController.text) != captchaAnswer) {
      _showError("Incorrect Captcha answer");
      _generateCaptcha();
      return;
    }

    setState(() => _isLoading = true);

    try {
      var result = await ApiService.login(email: email, password: password);
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServiceBookingScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Login failed", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(60),
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    "Welcome back to\nMotoBuddy.",
                    style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.motorcycle, size: 40, color: Colors.black),
                                const SizedBox(width: 10),
                                Text(
                                  "MotoBuddy",
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                  tooltip: "Back to Home",
                                )
                              ],
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "Sign In",
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Enter your email and password to access your account.",
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                            ),
                            const SizedBox(height: 40),
                            const Text("Email or Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  hintText: "Enter your email or phone",
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (value) => value!.isEmpty ? "Required field" : null,
                              ),
                            const SizedBox(height: 20),
                            const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  hintText: "Enter your password",
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                validator: (value) => value!.isEmpty ? "Required field" : null,
                              ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                  );
                                },
                                child: Text("Forgot Password?", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 20),
                      TextFormField(
                        controller: _captchaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Captcha: $num1 + $num2 = ?",
                          prefixIcon: const Icon(Icons.security),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _generateCaptcha,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Captcha is required";
                          }
                          if (int.tryParse(value) != captchaAnswer) {
                            return "Incorrect Captcha answer";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.black)
                                    : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? ", style: TextStyle(fontSize: 16)),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "Register Now",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
