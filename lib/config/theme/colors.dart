import 'package:flutter/material.dart';

/// Neumorphic + Minimalist Color Palette
///
/// Soft, muted colors with warm undertones designed for
/// neumorphic shadow effects and visual comfort.
class AppColors {
  AppColors._();

  // ============ NEUMORPHIC BASE COLORS ============

  /// Primary surface - warm cream/gray for neumorphic effects
  static const Color surface = Color(0xFFF0F4F8); // Soft blue-gray
  static const Color surfaceAlt = Color(0xFFE8ECF0); // Slightly darker for contrast
  static const Color surfaceVariant = Color(0xFFDCE2E8); // Input fields, pressed states

  /// Background - slightly off-white with warmth
  static const Color background = Color(0xFFF5F7FA); // Clean, warm white

  // ============ PRIMARY PALETTE - Muted Teal ============

  static const Color primary = Color(0xFF3D7A8C); // Softer, muted teal
  static const Color primaryLight = Color(0xFF5A9AAD); // Lighter variant
  static const Color primaryDark = Color(0xFF2A5A68); // Deeper variant
  static const Color primary50 = Color(0xFFE6F2F5); // Very light tint
  static const Color primary100 = Color(0xFFCCE5EB); // Light containers
  static const Color primary200 = Color(0xFF99CAD6); // Subtle accents
  static const Color primary700 = Color(0xFF1E4A58); // Deep accent
  static const Color primary900 = Color(0xFF0F2D36); // Deepest accent

  // ============ SECONDARY PALETTE - Sage Green ============

  static const Color secondary = Color(0xFF7CB69A); // Muted sage
  static const Color secondaryLight = Color(0xFF9ECAB4); // Lighter sage
  static const Color secondaryDark = Color(0xFF5A9A7D); // Deeper sage
  static const Color secondary50 = Color(0xFFEDF5F1); // Very light tint
  static const Color secondary100 = Color(0xFFD9EBE2); // Light containers
  static const Color secondary600 = Color(0xFF5A9A7D); // Main shade
  static const Color secondary700 = Color(0xFF4A8269); // Deep accent

  // ============ ACCENT PALETTE - Warm Coral ============

  static const Color accent = Color(0xFFE8967A); // Muted coral
  static const Color accentLight = Color(0xFFF0B09A);
  static const Color accentDark = Color(0xFFD4785C);

  // ============ TEXT COLORS ============

  /// Primary text - soft charcoal, not pure black
  static const Color textPrimary = Color(0xFF2D3748); // Warm charcoal
  static const Color textSecondary = Color(0xFF718096); // Muted gray
  static const Color textTertiary = Color(0xFFA0AEC0); // Light gray
  static const Color textOnPrimary = Color(0xFFFAFAFA); // Off-white
  static const Color textMuted = Color(0xFFCBD5E0); // Very muted

  // ============ STATUS COLORS - Muted versions ============

  static const Color success = Color(0xFF68B984); // Muted green
  static const Color warning = Color(0xFFE5A84C); // Muted amber
  static const Color error = Color(0xFFE57373); // Muted red
  static const Color info = Color(0xFF64B5F6); // Muted blue

  // ============ TOUR TYPE COLORS ============

  static const Color walkingTour = Color(0xFF68B984);
  static const Color drivingTour = Color(0xFF7986CB);

  // ============ CATEGORY COLORS - Muted palette ============

  static const Color historyCategory = Color(0xFF9575CD); // Muted purple
  static const Color natureCategory = Color(0xFF68B984); // Muted green
  static const Color ghostCategory = Color(0xFF78909C); // Blue gray
  static const Color foodCategory = Color(0xFFE8967A); // Muted coral
  static const Color artCategory = Color(0xFFF06292); // Muted pink
  static const Color architectureCategory = Color(0xFF4DB6AC); // Muted cyan

  // ============ DARK THEME - Neumorphic Dark ============

  /// Dark surface - deep blue-gray for neumorphic effects
  static const Color backgroundDark = Color(0xFF1A1F2E); // Deep blue-gray
  static const Color surfaceDark = Color(0xFF242938); // Elevated surface
  static const Color surfaceElevatedDark = Color(0xFF2E3446); // More elevated
  static const Color surfaceVariantDark = Color(0xFF3A4255); // Input fields

  /// Dark text
  static const Color textPrimaryDark = Color(0xFFF0F4F8); // Soft white
  static const Color textSecondaryDark = Color(0xFFA0AEC0); // Muted

  // ============ NEUMORPHIC SHADOW COLORS ============

  /// Light theme shadows
  static const Color shadowLight = Color(0xFFD1D9E6); // Soft shadow
  static const Color highlightLight = Color(0xFFFFFFFF); // Highlight

  /// Dark theme shadows
  static const Color shadowDark = Color(0xFF0A0C10); // Deep shadow
  static const Color highlightDark = Color(0xFF3A4255); // Subtle highlight
}
