import 'package:flutter/material.dart';

/// App color constants for E-Healthy
/// Theme: Blue & White for Health/Medical Application
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ═══════════════════════════════════════════
  // PRIMARY COLORS (Blue Theme)
  // ═══════════════════════════════════════════
  
  /// Main primary blue - #2196F3
  static const Color primaryBlue = Color(0xFF2196F3);
  
  /// Darker shade for emphasis - #1976D2
  static const Color primaryDark = Color(0xFF1976D2);
  
  /// Light blue for accents - #BBDEFB
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  /// Extra light blue for subtle backgrounds - #E3F2FD
  static const Color primaryExtraLight = Color(0xFFE3F2FD);

  // ═══════════════════════════════════════════
  // BACKGROUND COLORS
  // ═══════════════════════════════════════════
  
  /// Pure white for main background
  static const Color white = Color(0xFFFFFFFF);
  
  /// Off-white for cards and sections - #F5F9FC
  static const Color offWhite = Color(0xFFF5F9FC);
  
  /// Light grey for dividers and borders - #E0E0E0
  static const Color lightGrey = Color(0xFFE0E0E0);

  // ═══════════════════════════════════════════
  // ACCENT COLORS (Semantic Colors)
  // ═══════════════════════════════════════════
  
  /// Success green for positive actions - #4CAF50
  static const Color success = Color(0xFF4CAF50);
  
  /// Warning orange for alerts - #FF9800
  static const Color warning = Color(0xFFFF9800);
  
  /// Error red for errors and delete - #F44336
  static const Color error = Color(0xFFF44336);
  
  /// Info cyan for informational messages - #00BCD4
  static const Color info = Color(0xFF00BCD4);

  // ═══════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════
  
  /// Primary text color - #212121
  static const Color textPrimary = Color(0xFF212121);
  
  /// Secondary text color - #757575
  static const Color textSecondary = Color(0xFF757575);
  
  /// Disabled text color - #BDBDBD
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// Text on primary color (white)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════
  // GRADIENT COLORS
  // ═══════════════════════════════════════════
  
  /// Primary gradient (for AppBar, Buttons, etc.)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Soft gradient for backgrounds
  static const LinearGradient softGradient = LinearGradient(
    colors: [white, primaryExtraLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════════
  // SHADOW COLORS
  // ═══════════════════════════════════════════
  
  /// Subtle shadow for cards
  static Color shadowSubtle = Colors.black.withOpacity(0.05);
  
  /// Medium shadow for floating elements
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  
  /// Strong shadow for elevated elements
  static Color shadowStrong = Colors.black.withOpacity(0.12);
}
