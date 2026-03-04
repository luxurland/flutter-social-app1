import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF0B5FFF),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF0B5FFF),
      secondary: Color(0xFF00C2D1),
      surface: Colors.white,
      background: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0B5FFF),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Color(0xFFF5F9FF),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF0B5FFF),
    scaffoldBackgroundColor: Color(0xFF0F172A),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF0B5FFF),
      secondary: Color(0xFF00C2D1),
      surface: Color(0xFF1E293B),
      background: Color(0xFF0F172A),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0B5FFF),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E293B),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
