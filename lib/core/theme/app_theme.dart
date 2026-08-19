import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';

/// Centralized Material 3 Theme definitions for Light and Dark modes.
abstract class AppTheme {
  // Light Theme Color Tokens
  static const Color lightBackground = Color(0xFFF8F6F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceBorder = Color(0xFFE5DFD5);
  static const Color lightTextPrimary = Color(0xFF1C1917);
  static const Color lightTextSecondary = Color(0xFF78716C);

  /// Light Mode Theme Data (Default)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tealAccent,
        primary: AppColors.tealAccent,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextSecondary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightBackground,
        foregroundColor: AppColors.tealAccent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.tealAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightSurfaceBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: AppColors.tealAccent,
        unselectedItemColor: lightTextSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: lightSurfaceBorder,
        space: 1,
        thickness: 1,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.tealAccent;
          }
          return lightTextSecondary;
        }),
      ),
    );
  }

  /// Dark Mode Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tealAccent,
        primary: AppColors.tealAccent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.tealAccent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.tealAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.tealAccent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        space: 1,
        thickness: 1,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.tealAccent;
          }
          return AppColors.textSecondary;
        }),
      ),
    );
  }
}
