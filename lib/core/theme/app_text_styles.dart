import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text styles for E-Healthy app
/// Using clear hierarchy for better readability
class AppTextStyles {
  // Private constructor
  AppTextStyles._();

  // ═══════════════════════════════════════════
  // HEADINGS
  // ═══════════════════════════════════════════

  /// Large heading - 24px, Bold
  /// Usage: Page titles, major sections
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Medium heading - 20px, SemiBold
  /// Usage: Section titles, card headers
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Small heading - 18px, SemiBold
  /// Usage: Subsections, dialog titles
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ═══════════════════════════════════════════
  // BODY TEXT
  // ═══════════════════════════════════════════

  /// Large body text - 16px, Regular
  /// Usage: Main content, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Medium body text - 14px, Regular
  /// Usage: Standard text, list items
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Small body text - 12px, Regular
  /// Usage: Captions, helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ═══════════════════════════════════════════
  // BUTTON TEXT
  // ═══════════════════════════════════════════

  /// Primary button text - 16px, SemiBold
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.5,
  );

  /// Secondary button text - 14px, SemiBold
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════
  // SPECIAL TEXT STYLES
  // ═══════════════════════════════════════════

  /// Caption text - 12px, Regular, Secondary color
  /// Usage: Timestamps, metadata
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Overline text - 10px, Medium, Uppercase
  /// Usage: Labels, categories
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  /// AppBar title - 20px, Bold, White
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.15,
  );

  /// Input field text - 16px, Regular
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Input field label - 16px, Regular, Secondary
  static const TextStyle inputLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Input field hint - 16px, Regular, Disabled
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDisabled,
  );
}
