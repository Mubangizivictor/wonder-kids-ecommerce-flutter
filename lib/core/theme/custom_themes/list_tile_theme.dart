import 'package:flutter/material.dart';
import '../app_colors.dart';

class CustomListTileTheme {
  static const ListTileThemeData light = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minLeadingWidth: 40,
    horizontalTitleGap: 12,

    selectedTileColor: AppColors.primaryLight,

    iconColor: AppColors.onSurfaceLight,
    textColor: AppColors.onSurfaceLight,

    dense: false,
    shape: RoundedRectangleBorder(side: BorderSide.none),
  );

  static const ListTileThemeData dark = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minLeadingWidth: 40,
    horizontalTitleGap: 12,

    selectedTileColor: AppColors.primaryDark,

    iconColor: AppColors.onSurfaceDark,
    textColor: AppColors.onSurfaceDark,

    dense: false,
    shape: RoundedRectangleBorder(side: BorderSide.none),
  );
}
