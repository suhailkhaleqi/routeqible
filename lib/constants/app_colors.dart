import 'package:flutter/material.dart';

/// Centralized color palette for RouteQible's visual theme.
/// Establishes a rich dark espresso, warm dark brown, and vibrant teal accent system.
abstract class AppColors {
  // Page background & card surfaces (Dark Theme matching reference screenshot)
  static const background = Color(0xFF121110);
  static const surface = Color(0xFF1E1B17);
  static const surfaceBorder = Color(0xFF2E2922);

  // Typography
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9E978C);

  // RouteQible Teal/Green accent (matches title, pin icon & active prayer)
  static const tealAccent = Color(0xFF26A69A);

  // Compass dark brown & gold references
  static const darkBrownStart = Color(0xFF3A1E05);
  static const darkBrownEnd = Color(0xFF180A00);
  static const goldBright = Color(0xFFEDC85A);
  static const goldMid = Color(0xFFC09020);
}
