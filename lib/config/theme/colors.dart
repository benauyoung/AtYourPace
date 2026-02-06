import 'package:flutter/material.dart';

/// Parisian Botanical Journal Color Palette
///
/// A warm garden-green palette inspired by Parisian botanical journals,
/// bouquiniste walking guides, and luxury travel magazines.
/// Primary: Deep Garden Green | Accent: Antique Gold | Surface: Ivory Cream
class AppColors {
  AppColors._();

  // ============ BASE SURFACES ============

  /// Primary surface - warm parchment
  static const Color surface = Color(0xFFF2EDE4); // Warm Parchment
  static const Color surfaceAlt = Color(0xFFEBE5D8); // Card Parchment
  static const Color surfaceVariant = Color(0xFFE3DDD0); // Deeper parchment

  /// Background - ivory cream
  static const Color background = Color(0xFFF5F0E8); // Ivory Cream

  // ============ PRIMARY PALETTE - Deep Garden Green ============

  static const Color primary = Color(0xFF4A6741); // Deep Garden Green
  static const Color primaryLight = Color(0xFF6B8A5E); // Soft Sage
  static const Color primaryDark = Color(0xFF3D5636); // Dark Ivy
  static const Color primary50 = Color(0xFFEEF2EC); // Very light green tint
  static const Color primary100 = Color(0xFFD5E0D1); // Light green containers
  static const Color primary200 = Color(0xFFB0C5A8); // Subtle green accents
  static const Color primary700 = Color(0xFF354D2E); // Deep green
  static const Color primary900 = Color(0xFF243620); // Deepest green

  // ============ SECONDARY PALETTE - Warm Parchment ============

  static const Color secondary = Color(0xFFEBE5D8); // Card Parchment
  static const Color secondaryLight = Color(0xFFF2EDE4); // Warm Parchment
  static const Color secondaryDark = Color(0xFFE0DAC9); // Weathered Parchment
  static const Color secondary50 = Color(0xFFFAF8F4); // Very light parchment
  static const Color secondary100 = Color(0xFFF5F0E8); // Ivory Cream
  static const Color secondary600 = Color(0xFFD8D1C2); // Main shade
  static const Color secondary700 = Color(0xFFCCC4B3); // Deep parchment

  // ============ ACCENT PALETTE - Antique Gold & Warm Tones ============

  static const Color accent = Color(0xFFC4A55A); // Antique Gold (stars, fun-facts, audio progress)
  static const Color accentLight = Color(0xFFD4BA7A); // Light Gold
  static const Color accentDark = Color(0xFFA88C42); // Deep Gold

  // ============ TEXT COLORS - Green-tinted warm blacks ============

  /// Primary text - warm charcoal (green-tinted, never pure black)
  static const Color textPrimary = Color(0xFF2D3A29); // Warm Charcoal
  static const Color textSecondary = Color(0xFF6B6459); // Stone Gray
  static const Color textTertiary = Color(0xFF8A8577); // Muted Taupe
  static const Color textOnPrimary = Color(0xFFF5F0E8); // Ivory Cream
  static const Color textMuted = Color(0xFFB5AFA3); // Very muted taupe

  // ============ BORDER COLORS ============

  static const Color borderLinen = Color(0xFFE0DBD1); // Primary dividers, card borders
  static const Color borderLinenLight = Color(0xFFE8E3DA); // Subtle borders

  // ============ STATUS COLORS - Warm muted versions ============

  static const Color success = Color(0xFF4A6741); // Garden green (matches primary)
  static const Color warning = Color(0xFFC4A55A); // Antique gold
  static const Color error = Color(0xFFC4725C); // Muted terracotta
  static const Color info = Color(0xFF6B8A5E); // Soft sage

  // ============ TOUR TYPE COLORS ============

  static const Color walkingTour = Color(0xFF4A6741); // Garden green
  static const Color drivingTour = Color(0xFF8D7B6A); // Warm taupe

  // ============ CATEGORY COLORS - Botanical palette ============

  static const Color historyCategory = Color(0xFF8B7355); // Aged leather
  static const Color natureCategory = Color(0xFF4A6741); // Garden green
  static const Color ghostCategory = Color(0xFF6B7B8A); // Misty slate
  static const Color foodCategory = Color(0xFFC4725C); // Terracotta
  static const Color artCategory = Color(0xFFC4A55A); // Antique gold
  static const Color architectureCategory = Color(0xFF7A6E5E); // Warm stone

  // ============ DARK THEME - Midnight Garden ============

  /// Dark surface - deep green-tinted umber
  static const Color backgroundDark = Color(0xFF1A1E18); // Deep garden night
  static const Color surfaceDark = Color(0xFF252A22); // Elevated garden dark
  static const Color surfaceElevatedDark = Color(0xFF303628); // More elevated
  static const Color surfaceVariantDark = Color(0xFF3E4538); // Input fields

  /// Dark text
  static const Color textPrimaryDark = Color(0xFFF2EDE4); // Warm Parchment
  static const Color textSecondaryDark = Color(0xFFB5AFA3); // Muted Taupe

  // ============ GLASSMORPHIC COLORS ============

  /// Glass panel tints (ivory cream based)
  static const Color glassHeavy = Color(0xD9F5F0E8); // 85% ivory cream
  static const Color glassMedium = Color(0xA6F5F0E8); // 65% ivory cream
  static const Color glassLight = Color(0x66F5F0E8); // 40% ivory cream
  static const Color glassWhisper = Color(0x26F5F0E8); // 15% ivory cream

  /// Glass borders
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% white
  static const Color glassBorderSubtle = Color(0x26FFFFFF); // 15% white

  /// Shadow colors - green-tinted charcoal
  static const Color shadowLight = Color(0xFF2D3A29); // Warm charcoal shadow base
  static const Color highlightLight = Color(0xFFFFFDF8); // Warm highlight

  /// Dark theme shadows
  static const Color shadowDark = Color(0xFF0A0D09); // Deep green-tinted shadow
  static const Color highlightDark = Color(0xFF3E4538); // Subtle warm highlight
}
