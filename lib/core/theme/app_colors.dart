import 'package:flutter/material.dart';

class AppColors {
  // Wonder Kids - Playful Pink & Blue Palette
  static const Color primaryLight = Color(0xFFFF6B9D); // Playful Pink
  static const Color primaryDark = Color(0xFFFF8EBC);

  static const Color primaryContainerLight = Color(0xFFFCE4EC); // Soft Pink
  static const Color primaryContainerDark = Color(0xFF392D32);

  // Kids secondary - Sky Blue
  static const Color secondaryLight = Color(0xFF4FC3F7);
  static const Color secondaryDark = Color(0xFF81D4FA);

  // Light mode - Soft and Friendly
  static const Color backgroundLight = Color(0xFFFFF9FB); // Very Light Pink tint
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF2D2D2D);

  // Dark mode - Playful dark
  static const Color backgroundDark = Color(0xFF1A1617); // Dark Plum/Black
  static const Color surfaceDark = Color(0xFF2D2426); 
  static const Color onSurfaceDark = Color(0xFFFFF0F5); // Lavender Blush

  // Text on primary
  static const Color onPrimaryLight = Colors.white;
  static const Color onPrimaryDark = Color(0xFF111111);

  // Status & Accents
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color rating = Color(0xFFFFC107);
  static const Color gold = Color(0xFFD4AF37);
  static const Color info = Color(0xFF64B5F6);
  static const Color warning = Color(0xFFFFB74D);
  static const Color midnightBlack = Color(0xFF0F1115);

  // Transparent / Overlays (Avoid withAlpha/withOpacity in code)
  static const Color transparent = Colors.transparent;
  static const Color overlayDark = Color(0x99000000); // 60% black
  static const Color overlayLight = Color(0xCCFFFFFF); // 80% white
  static const Color cardShadowLight = Color(0x14000000); // 8% black
  static const Color cardShadowDark = Color(0x66000000); // 40% black
  static const Color dividerLight = Color(0x1F000000); // ~12% black
  static const Color starGrey = Color(0xFFBDBDBD);

  // Semantic Opacity Variants (pre-calculated to avoid .withOpacity)
  static const Color primaryLight10 = Color(0x1AFF6B9D);
  static const Color primaryLight20 = Color(0x33FF6B9D);
  static const Color primaryLight30 = Color(0x4DFF6B9D);
  static const Color primaryDark10 = Color(0x1AFF8EBC);
  static const Color primaryDark20 = Color(0x33FF8EBC);

  static const Color onSurfaceLight10 = Color(0x1A2D2D2D);
  static const Color onSurfaceLight40 = Color(0x662D2D2D);
  static const Color onSurfaceLight60 = Color(0x992D2D2D);
  
  static const Color onSurfaceDark10 = Color(0x1AFFF0F5);
  static const Color onSurfaceDark40 = Color(0x66FFF0F5);
  static const Color onSurfaceDark60 = Color(0x99FFF0F5);

  static const Color gold10 = Color(0x1AD4AF37);
  static const Color gold20 = Color(0x33D4AF37);
  static const Color gold30 = Color(0x4DD4AF37);
  static const Color gold50 = Color(0x80D4AF37);
}
