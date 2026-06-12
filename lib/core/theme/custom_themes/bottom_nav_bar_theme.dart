// utils/theme/custom_themes/bottom_nav_bar_theme.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';

class CustomBottomNavBarTheme {
  static NavigationBarThemeData light = NavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    surfaceTintColor: Colors.transparent,
    indicatorColor: AppColors.primaryLight,
    indicatorShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    iconTheme: WidgetStateProperty.all(
      const IconThemeData(
        size: 24,
      ),
    ),
    elevation: 0,
    height: 65,
  );

  static NavigationBarThemeData dark = NavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    surfaceTintColor: Colors.transparent,
    indicatorColor: AppColors.primaryDark,
    indicatorShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    iconTheme: WidgetStateProperty.all(
      const IconThemeData(
        size: 24,
      ),
    ),
    elevation: 0,
    height: 65,
  );
}