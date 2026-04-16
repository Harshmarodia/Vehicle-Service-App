import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules/auth/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'modules/shell/admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool logged = await ApiService.isLoggedIn();
  runApp(MotoBuddyAdminApp(isLoggedIn: logged));
}

class MotoBuddyAdminApp extends StatelessWidget {
  final bool isLoggedIn;
  const MotoBuddyAdminApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoBuddy Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Apply Google Fonts globally
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          ),
          child: child!,
        );
      },
      home: isLoggedIn ? const AdminShell() : const AdminLoginScreen(),
      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminShell(),
      },
    );
  }
}
