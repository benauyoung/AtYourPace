import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'colors.dart';
import 'neumorphic.dart';
import 'typography.dart';

/// Neumorphic + Minimalist Theme
///
/// Soft, extruded UI with generous whitespace and Geist typography.
class AppTheme {
  AppTheme._();

  // ============ LIGHT THEME ============

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme - muted, soft palette
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primary50,
      onPrimaryContainer: AppColors.primary700,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.secondary50,
      onSecondaryContainer: AppColors.secondary700,
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
    ),

    // Neumorphic background
    scaffoldBackgroundColor: AppColors.background,

    // Typography - Geist
    textTheme: AppTypography.lightTextTheme,

    // App bar - clean, minimal
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.lightTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),

    // Cards - neumorphic with soft shadows
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated buttons - neumorphic raised
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(0, AppSpacing.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Filled buttons - primary action
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(0, AppSpacing.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Outlined buttons - secondary action
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(0, AppSpacing.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Text buttons - tertiary action
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Input decoration - neumorphic inset
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: AppSpacing.inputPadding,
      hintStyle: AppTypography.lightTextTheme.bodyMedium?.copyWith(
        color: AppColors.textTertiary,
      ),
    ),

    // Chips - pill shaped, subtle
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary100,
      labelStyle: AppTypography.lightTextTheme.labelMedium,
      secondaryLabelStyle: AppTypography.lightTextTheme.labelMedium?.copyWith(
        color: AppColors.textOnPrimary,
      ),
      side: BorderSide(color: AppColors.surfaceVariant, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Navigation bar - clean bottom nav
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      height: 72,
      elevation: 0,
      indicatorColor: AppColors.primary100,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return IconThemeData(color: AppColors.textSecondary, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.lightTextTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.lightTextTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        );
      }),
    ),

    // Bottom navigation bar (fallback)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // FAB - neumorphic raised
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),

    // Dialogs - generous padding
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      titleTextStyle: AppTypography.lightTextTheme.titleLarge,
      contentTextStyle: AppTypography.lightTextTheme.bodyMedium,
    ),

    // Bottom sheets
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.sheetRadius,
      ),
      dragHandleColor: AppColors.surfaceVariant,
      dragHandleSize: const Size(40, 4),
    ),

    // Dividers - subtle
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
      space: 1,
    ),

    // Snackbars
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.lightTextTheme.bodyMedium?.copyWith(
        color: AppColors.surface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    // List tiles
    listTileTheme: ListTileThemeData(
      contentPadding: AppSpacing.listPadding,
      minVerticalPadding: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    ),

    // Switches
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary200;
        }
        return AppColors.surfaceVariant;
      }),
    ),

    // Checkboxes
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Sliders
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceVariant,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.12),
    ),

    // Progress indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceVariant,
    ),

    // Tab bar
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.lightTextTheme.labelLarge,
      unselectedLabelStyle: AppTypography.lightTextTheme.labelLarge,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );

  // ============ DARK THEME ============

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme - deep, muted
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primary100,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondary100,
      tertiary: AppColors.accentLight,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
    ),

    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: AppTypography.darkTextTheme,

    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.darkTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),

    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(0, AppSpacing.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(0, AppSpacing.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(0, AppSpacing.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: AppSpacing.inputPadding,
      hintStyle: AppTypography.darkTextTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.primaryDark,
      labelStyle: AppTypography.darkTextTheme.labelMedium,
      side: BorderSide(color: AppColors.surfaceVariantDark, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      height: 72,
      elevation: 0,
      indicatorColor: AppColors.primaryDark,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryLight, size: 24);
        }
        return IconThemeData(color: AppColors.textSecondaryDark, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.darkTextTheme.labelSmall?.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.darkTextTheme.labelSmall?.copyWith(
          color: AppColors.textSecondaryDark,
        );
      }),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      titleTextStyle: AppTypography.darkTextTheme.titleLarge,
      contentTextStyle: AppTypography.darkTextTheme.bodyMedium,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.sheetRadius,
      ),
      dragHandleColor: AppColors.surfaceVariantDark,
      dragHandleSize: const Size(40, 4),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariantDark,
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevatedDark,
      contentTextStyle: AppTypography.darkTextTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: AppSpacing.listPadding,
      minVerticalPadding: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.surfaceVariantDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.surfaceVariantDark;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryLight,
      inactiveTrackColor: AppColors.surfaceVariantDark,
      thumbColor: AppColors.primaryLight,
      overlayColor: AppColors.primaryLight.withOpacity(0.12),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.surfaceVariantDark,
    ),

    tabBarTheme: TabBarTheme(
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.textSecondaryDark,
      labelStyle: AppTypography.darkTextTheme.labelLarge,
      unselectedLabelStyle: AppTypography.darkTextTheme.labelLarge,
      indicatorColor: AppColors.primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );
}
