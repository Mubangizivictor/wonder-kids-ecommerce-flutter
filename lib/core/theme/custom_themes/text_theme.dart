// theme/custom_themes/text_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class CustomTextTheme {
  static TextTheme light = TextTheme(
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, 
      color: AppColors.onSurfaceLight,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, 
      color: AppColors.onSurfaceLight,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20, 
      fontWeight: FontWeight.w600, 
      color: AppColors.onSurfaceLight,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 18, 
      fontWeight: FontWeight.w500, 
      color: AppColors.onSurfaceLight,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, 
      fontWeight: FontWeight.w500, 
      color: AppColors.onPrimaryLight,
    ),
  );

  static TextTheme dark = TextTheme(
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, 
      color: AppColors.onSurfaceDark,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, 
      color: AppColors.onSurfaceDark,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20, 
      fontWeight: FontWeight.w600, 
      color: AppColors.onSurfaceDark,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 18, 
      fontWeight: FontWeight.w500, 
      color: AppColors.onSurfaceDark,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, 
      fontWeight: FontWeight.w500, 
      color: AppColors.primaryDark,
    ),
  );
}