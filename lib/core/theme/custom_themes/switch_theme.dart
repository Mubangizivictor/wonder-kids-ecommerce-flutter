// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../app_colors.dart';

class CustomSwitchTheme {
  static SwitchThemeData light = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      return Colors.grey.shade400;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0x80FF6B9D); // AppColors.primaryLight with 0.5 opacity
      }
      return Colors.grey.shade300;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  static SwitchThemeData dark = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDark;
      }
      return Colors.grey.shade500;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0x80FF8EBC); // AppColors.primaryDark with 0.5 opacity
      }
      return Colors.grey.shade700;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );
}