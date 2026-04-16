import 'package:flutter/material.dart';
import 'modules/auth/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MotoBuddyAgentApp());
}

class MotoBuddyAgentApp extends StatelessWidget {
  const MotoBuddyAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoBuddy Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AgentLoginScreen(),
    );
  }
}
