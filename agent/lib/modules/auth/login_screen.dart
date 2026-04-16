import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'register_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'waiting_screen.dart';

class AgentLoginScreen extends StatefulWidget {
  const AgentLoginScreen({super.key});

  @override
  State<AgentLoginScreen> createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends State<AgentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  bool _isLoading = false;

  late int num1, num2, captchaAnswer;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  @override
  void dispose() {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

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
    final result = await ApiService.agentLogin(email: email, password: password);
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AgentDashboardScreen()),
      );
    } else {
      if (!mounted) return;
      if (result['message'] != null && result['message'].toString().contains('pending')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Image/Decoration
          if (MediaQuery.of(context).size.width >= 1000)
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Image.network(
                        "https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?auto=format&fit=crop&w=1200&q=80",
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_circle_rounded, size: 80, color: Color(0xFFFFD700)),
                          SizedBox(height: 20),
                          Text(
                            "MotoBuddy Agent",
                            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Manage your garage efficiently.",
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Right Side - Login Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 600 ? 30 : 60,
                vertical: 40
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome Back", style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: 10),
                    const Text("Sign in to access your garage dashboard.", style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 40),
                    const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: "Enter your email", prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "Enter your password", prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => v!.isEmpty ? "Required" : null,
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                            : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentRegisterScreen())),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text("Register Garage", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailResetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your registered email to receive reset instructions."),
            const SizedBox(height: 20),
            TextField(
              controller: emailResetController,
              decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final email = emailResetController.text.trim();
              if (email.isEmpty) return;
              
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final res = await ApiService.agentForgotPassword(email);
              setState(() => _isLoading = false);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? "Instructions sent!"),
                    backgroundColor: res['success'] == true ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Reset Password"),
          ),
        ],
      ),
    );
  }
}
