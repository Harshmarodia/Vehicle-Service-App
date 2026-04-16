import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/login_screen.dart';
import 'modules/dashboard/dashboard_screen.dart';
import 'modules/auth/register_screen.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLoggedIn = await ApiService.isLoggedIn();
  
  runApp(MechanicHubApp(initialRoute: isLoggedIn ? '/dashboard' : '/login'));
}

class MechanicHubApp extends StatelessWidget {
  final String initialRoute;
  const MechanicHubApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoBuddy | Mechanic Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
