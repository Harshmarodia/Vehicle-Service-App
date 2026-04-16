import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  List<dynamic> _agents = [];
  String? _selectedAgentId;
  bool _isLoading = false;
  bool _isFetchingAgents = true;

  @override
  void initState() {
    super.initState();
    _fetchAgents();
  }

  Future<void> _fetchAgents() async {
    final res = await ApiService.getAllAgents();
    if (mounted) {
      setState(() {
        _agents = res['success'] ? res['agents'] : [];
        _isFetchingAgents = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAgentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a garage")));
      return;
    }
    
    setState(() => _isLoading = true);

    final res = await ApiService.registerMechanic(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      agentId: _selectedAgentId!,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration successful! Please login.")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Error registering")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mechanic Registration")),
      body: _isFetchingAgents 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Join the MotoBuddy network as a field mechanic.", style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedAgentId,
                decoration: const InputDecoration(labelText: "Select Garage", prefixIcon: Icon(Icons.garage_outlined)),
                items: _agents.map((agent) {
                  return DropdownMenuItem<String>(
                    value: agent['_id'],
                    child: Text(agent['garageName'] ?? agent['name']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedAgentId = v),
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Create Password", prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Register as Mechanic"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
