import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryRed = Color(0xFFFF4D4D);
  static const Color secondaryOrange = Color(0xFFFF9F1C);
  static const Color accentBlue = Color(0xFF00C2FF);

  // Background Colors
  static const Color lightBackground = Color(0xFFFFF5F5);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3A3A3A);

  // Alarm State Colors
  static const Color alarmActive = Color(0xFFFF4D4D);
  static const Color alarmInactive = Color(0xFF9E9E9E);
  static const Color alarmSnooze = Color(0xFFFF9F1C);

  // Gradient Colors
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryRed, secondaryOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get appBarGradient => const LinearGradient(
        colors: [primaryRed, secondaryOrange],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient get alarmRingGradient => LinearGradient(
        colors: [
          primaryRed.withOpacity(0.8),
          secondaryOrange.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
