import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors - Fresh teal/navy inspired by Shaka Guide
  static const Color primary = Color(0xFF1E3D4C); // Dark teal navy (nav bars, buttons)
  static const Color primaryLight = Color(0xFF2C5364); // Lighter teal
  static const Color primaryDark = Color(0xFF152A35); // Darker navy
  static const Color primary50 = Color(0xFFE8F4F8); // Very light tint
  static const Color primary100 = Color(0xFFD1E9F0); // Light containers
  static const Color primary200 = Color(0xFFB3D9E5); // Subtle accents
  static const Color primary700 = Color(0xFF152A35); // Deep accent
  static const Color primary900 = Color(0xFF0D1B22); // Deepest accent

  // Secondary/Accent colors - Mint teal (CTA buttons, highlights)
  static const Color secondary = Color(0xFF5DD4B3); // Fresh mint teal
  static const Color secondaryLight = Color(0xFF7DE4C8); // Lighter mint
  static const Color secondaryDark = Color(0xFF3DC49A); // Deeper mint
  static const Color secondary50 = Color(0xFFE6FAF5); // Very light mint tint
  static const Color secondary100 = Color(0xFFCCF5EB); // Light mint containers
  static const Color secondary600 = Color(0xFF3DC49A); // Main shade
  static const Color secondary700 = Color(0xFF2AB385); // Deep accent

  // Accent colors - Warm orange for prices and highlights
  static const Color accent = Color(0xFFFF9F43); // Warm orange
  static const Color accentLight = Color(0xFFFFBE76);
  static const Color accentDark = Color(0xFFE67E22);

  // Neutral colors - Clean and fresh
  static const Color background = Color(0xFFF5F7F9); // Light gray background
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceVariant = Color(0xFFEEF2F5); // Subtle gray

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Tour type colors
  static const Color walkingTour = Color(0xFF10B981);
  static const Color drivingTour = Color(0xFF6366F1);

  // Category colors
  static const Color historyCategory = Color(0xFF8B5CF6);
  static const Color natureCategory = Color(0xFF22C55E);
  static const Color ghostCategory = Color(0xFF6B7280);
  static const Color foodCategory = Color(0xFFF97316);
  static const Color artCategory = Color(0xFFEC4899);
  static const Color architectureCategory = Color(0xFF06B6D4);

  // Dark theme colors - Deeper, blue-tinted with better elevation
  static const Color backgroundDark = Color(0xFF0A0E1A); // Deeper, blue-tinted
  static const Color surfaceDark = Color(0xFF1A1F35); // Warmer dark
  static const Color surfaceElevatedDark = Color(0xFF242938); // Elevated surfaces
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
