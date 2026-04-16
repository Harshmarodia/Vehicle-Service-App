import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/web/landing/landing_page.dart';
import 'core/theme/app_theme.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme');
  if (theme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  }
  runApp(const MotoBuddyWeb());
}

class MotoBuddyWeb extends StatelessWidget {
  const MotoBuddyWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: "MotoBuddy",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const LandingPage(),
        );
      },
    );
  }
}