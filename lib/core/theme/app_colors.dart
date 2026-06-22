import 'package:flutter/material.dart';

/// Centralized design tokens for ALLAWI PDF Reader.
///
/// The palette is built around a confident indigo-blue brand color with
/// warm amber as an accent for highlights/bookmarks — distinct from the
/// generic "default Material purple" look of most template apps.
class AppColors {
  AppColors._();

  // Brand
  static const Color brand = Color(0xFF2F6FED); // primary indigo-blue
  static const Color brandDark = Color(0xFF1B4FCB);
  static const Color accentAmber = Color(0xFFF2A33D); // highlights/bookmarks
  static const Color accentTeal = Color(0xFF2BB3A3); // success/progress

  // Light theme surfaces
  static const Color lightBg = Color(0xFFF7F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF1F8);
  static const Color lightOutline = Color(0xFFDDE1EA);
  static const Color lightTextPrimary = Color(0xFF14171F);
  static const Color lightTextSecondary = Color(0xFF5B6270);

  // Dark theme surfaces
  static const Color darkBg = Color(0xFF0E1116);
  static const Color darkSurface = Color(0xFF161A21);
  static const Color darkSurfaceAlt = Color(0xFF1E232C);
  static const Color darkOutline = Color(0xFF2B313C);
  static const Color darkTextPrimary = Color(0xFFF2F4F8);
  static const Color darkTextSecondary = Color(0xFF9AA3B2);

  // Night reading mode (sepia-ish low-blue-light tone for the viewer page)
  static const Color nightReadingBg = Color(0xFF1A1812);
  static const Color sepiaReadingBg = Color(0xFFF4ECD8);

  // Semantic
  static const Color danger = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF2A33D);
  static const Color success = Color(0xFF2BB3A3);
}
