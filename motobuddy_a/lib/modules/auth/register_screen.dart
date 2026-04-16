import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'waiting_screen.dart';

class AgentRegisterScreen extends StatefulWidget {
  const AgentRegisterScreen({super.key});

  @override
  State<AgentRegisterScreen> createState() => _AgentRegisterScreenState();
}

class _AgentRegisterScreenState extends State<AgentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  String name = '', email = '', phone = '', password = '', garageName = '', address = '', pincode = '';
  bool _isLoading = false;

  late int num1, num2, captchaAnswer;

  @override
  void initState() {
    super.initState();
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Manual validation checks
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || garageName.isEmpty || address.isEmpty || pincode.isEmpty) {
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
      _generateCaptcha(); // Refresh captcha on incorrect attempt
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.agentRegister(
      name: name,
      email: email,
      phone: phone,
      password: password,
      garageName: garageName,
      address: address,
      pincode: pincode,
    );
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registration failed'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Your Garage"), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Garage Owner Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                          onSaved: (v) => name = v!,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone_outlined)),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                          onSaved: (v) => phone = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => email = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline)),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => password = v!,
                  ),
                  const SizedBox(height: 40),
                  const Text("Garage Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Garage Name", prefixIcon: Icon(Icons.garage_outlined)),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => garageName = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Full Address", prefixIcon: Icon(Icons.map_outlined)),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => address = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Serviceable Pincode", prefixIcon: Icon(Icons.location_on_outlined)),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (v) => v!.length != 6 ? "Enter 6-digit pincode" : null,
                    onSaved: (v) => pincode = v!,
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
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                          : const Text("Register Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
