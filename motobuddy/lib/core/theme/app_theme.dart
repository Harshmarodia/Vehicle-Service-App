import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.textWhite,
    fontFamily: "Inter",
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.dark,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1D21), // Matching new navbar
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: "Inter",
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF1A1D21), 
        fontWeight: FontWeight.w900, 
        fontSize: 36, 
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        color: Color(0xFF1A1D21), 
        fontWeight: FontWeight.w800, 
        fontSize: 28, 
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF1A1D21),
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      bodyLarge: TextStyle(color: Color(0xFF2D3238), fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: Color(0xFF4A4F55), fontSize: 14, height: 1.4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIconColor: Colors.black45,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.dark,
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800, 
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.dark,
    fontFamily: "Inter",
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.textWhite,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.textWhite),
      bodyMedium: TextStyle(color: AppColors.lightGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}
