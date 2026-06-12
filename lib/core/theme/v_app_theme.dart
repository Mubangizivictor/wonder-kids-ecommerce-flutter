import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'custom_themes/app_bar_theme.dart';
import 'custom_themes/bottom_nav_bar_theme.dart';
import 'custom_themes/divider_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/floating_button_theme.dart';
import 'custom_themes/input_decoration_theme.dart';
import 'custom_themes/list_tile_theme.dart';
import 'custom_themes/outlined_button_theme.dart';
import 'custom_themes/pop_up_menu_theme.dart';
import 'custom_themes/progress_indicator.dart';
import 'custom_themes/snack_bar_theme.dart';
import 'custom_themes/switch_theme.dart';
import 'custom_themes/text_theme.dart';
import 'custom_themes/time_picker.dart';

class VAppTheme {
  // Light theme - Warm cream/off-white background
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      surface: AppColors.surfaceLight,
      onPrimary: AppColors.onPrimaryLight,
      onSurface: AppColors.onSurfaceLight,
    ),
    appBarTheme: CustomAppBarTheme.light,
    elevatedButtonTheme: CustomElevatedButtonTheme.light,
    outlinedButtonTheme: CustomOutlinedButtonTheme.light,
    floatingActionButtonTheme: CustomFloatingButtonTheme.light,
    listTileTheme: CustomListTileTheme.light,
    inputDecorationTheme: CustomInputDecorationTheme.light,
    textTheme: CustomTextTheme.light,
    switchTheme: CustomSwitchTheme.light,
    dividerTheme: CustomDividerTheme.light,
    popupMenuTheme: CustomPopupMenuTheme.light,
    progressIndicatorTheme: CustomProgressIndicatorTheme.light,
    snackBarTheme: CustomSnackBarTheme.light,
    timePickerTheme: CustomTimePickerTheme.light,
    navigationBarTheme: CustomBottomNavBarTheme.light, // Changed from bottomNavigationBarTheme
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Dark theme - Brand's dark charcoal background
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.onPrimaryDark,
      onSurface: AppColors.onSurfaceDark,
    ),
    appBarTheme: CustomAppBarTheme.dark,
    elevatedButtonTheme: CustomElevatedButtonTheme.dark,
    outlinedButtonTheme: CustomOutlinedButtonTheme.dark,
    floatingActionButtonTheme: CustomFloatingButtonTheme.dark,
    listTileTheme: CustomListTileTheme.dark,
    inputDecorationTheme: CustomInputDecorationTheme.dark,
    textTheme: CustomTextTheme.dark,
    switchTheme: CustomSwitchTheme.dark,
    dividerTheme: CustomDividerTheme.dark,
    popupMenuTheme: CustomPopupMenuTheme.dark,
    progressIndicatorTheme: CustomProgressIndicatorTheme.dark,
    snackBarTheme: CustomSnackBarTheme.dark,
    timePickerTheme: CustomTimePickerTheme.dark,
    navigationBarTheme: CustomBottomNavBarTheme.dark, // Changed from bottomNavigationBarTheme
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}