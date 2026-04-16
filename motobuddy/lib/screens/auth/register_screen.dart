import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../core/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', phone = '', password = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  bool _isLoading = false;

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
    _generateCaptcha();
  }

  void _generateCaptcha() {
    setState(() {
      num1 = 1 + (DateTime.now().millisecond % 9);
      num2 = 1 + (DateTime.now().microsecond % 9);
      captchaAnswer = num1 + num2;
      _captchaController.clear();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
  }

  String vehicleType = 'Two Wheeler';
  String vehicleNumber = '';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || vehicleNumber.isEmpty) {
      _showError("All fields are required");
      return;
    }

    if (!RegExp(r"^[6-9]\d{9}$").hasMatch(phone)) {
      _showError("Enter a valid 10-digit Indian phone number starting with 6-9");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      _showError("Enter a valid email address");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    if (int.tryParse(_captchaController.text) != captchaAnswer) {
      _showError("Incorrect Captcha answer");
      _generateCaptcha();
      return;
    }

    setState(() => _isLoading = true);

    try {
      var result = await ApiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful! Please login.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Registration failed", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
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
                    "Join the\nMotoBuddy Community.",
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
                      width: 500,
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.motorcycle, size: 40),
                                const SizedBox(width: 10),
                                Text(
                                  "MotoBuddy",
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 28,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Fill in your details to start your journey with us.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  hintText: "Enter your full name",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) => value!.isEmpty ? "Required field" : null,
                                onChanged: (value) => name = value,
                                onSaved: (value) => name = value!,
                              ),
                            const SizedBox(height: 15),
                            const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  hintText: "Enter your email",
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Required field";
                                  return null;
                                },
                                onChanged: (value) => email = value,
                                onSaved: (value) => email = value!,
                              ),
                            const SizedBox(height: 15),
                            const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  hintText: "Enter your phone number",
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty ? "Required field" : null,
                                onChanged: (value) => phone = value,
                                onSaved: (value) => phone = value!,
                              ),
                            const SizedBox(height: 15),
                             Row(children: [
                               Expanded(
                                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                   const Text("Vehicle Type", style: TextStyle(fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 8),
                                   DropdownButtonFormField<String>(
                                     value: vehicleType,
                                     items: const [
                                       DropdownMenuItem(value: "Two Wheeler", child: Text("Two Wheeler")),
                                       DropdownMenuItem(value: "Four Wheeler", child: Text("Four Wheeler")),
                                     ],
                                     onChanged: (val) => setState(() => vehicleType = val!),
                                     decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                                   ),
                                 ]),
                               ),
                               const SizedBox(width: 15),
                               Expanded(
                                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                   const Text("Vehicle Number", style: TextStyle(fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 8),
                                   TextFormField(
                                     decoration: const InputDecoration(hintText: "GJ01 XX 0000"),
                                     onChanged: (val) => vehicleNumber = val,
                                     validator: (val) => val!.isEmpty ? "Required" : null,
                                   ),
                                 ]),
                               ),
                             ]),
                            const SizedBox(height: 15),
                            const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: "Create a password",
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) => value!.length < 6 ? "Password too short (min 6)" : null,
                                onChanged: (value) => password = value,
                                onSaved: (value) => password = value!,
                              ),
                            const SizedBox(height: 20),
                      TextFormField(
                        controller: _captchaController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Captcha: $num1 + $num2 = ?",
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          prefixIcon: Icon(Icons.security, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.black54),
                            onPressed: _generateCaptcha,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Required field";
                          if (int.tryParse(value) != captchaAnswer) return "Incorrect answer";
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.black)
                                    : const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? ", style: TextStyle(fontSize: 16)),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "Log In",
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
