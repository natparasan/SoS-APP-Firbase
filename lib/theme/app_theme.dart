import 'package:flutter/material.dart';

/// Central place for the app's vivid, high-contrast color palette and
/// reusable gradients — keeps every screen visually consistent.
class AppColors {
  static const emergencyRed = Color(0xFFFF3B5C);
  static const emergencyRedDark = Color(0xFFB4123A);
  static const violet = Color(0xFF7B2FF7);
  static const indigo = Color(0xFF4E54C8);
  static const teal = Color(0xFF11998E);
  static const amber = Color(0xFFF7B733);
  static const skyBlue = Color(0xFF2196F3);
  static const success = Color(0xFF2ECC71);
  static const surfaceDark = Color(0xFF14142B);

  static const sosGradient = LinearGradient(
    colors: [emergencyRed, emergencyRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [violet, indigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const monitorGradient = LinearGradient(
    colors: [teal, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunsetGradient = LinearGradient(
    colors: [amber, emergencyRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFF1B1035), Color(0xFF2B1655), Color(0xFF3A1361)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.violet,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F5FB),
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
