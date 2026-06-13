import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  // Display & Headlines (Plus Jakarta Sans)
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 56.0,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 40.0,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.plusJakartaSans(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static TextStyle headlineLarge = GoogleFonts.plusJakartaSans(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.plusJakartaSans(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Body & Labels (Manrope)
  static TextStyle titleLarge = GoogleFonts.manrope(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.manrope(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle titleSmall = GoogleFonts.manrope(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelLarge = GoogleFonts.manrope(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle labelMedium = GoogleFonts.manrope(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle labelSmall = GoogleFonts.manrope(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );
}
