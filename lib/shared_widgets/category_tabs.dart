// ignore_for_file: unused_local_variable

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';

/// A horizontal scrollable list of category tabs.
/// Uses the 'buttons_tabbar' package for a premium, tactile feel.
class CategoryTabs extends StatelessWidget {
  final List<dynamic> categories;
  final TabController? tabController;

  const CategoryTabs({
    super.key,
    required this.categories,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: ButtonsTabBar(
      controller: tabController,
      // Active Tab Styling
      backgroundColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      
      // Inactive Tab Styling
      unselectedBackgroundColor: theme.colorScheme.surface,
      unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface.withAlpha(150),
      ),
      
      // Border and Spacing
      borderWidth: 1,
      borderColor: theme.colorScheme.primary.withAlpha(80),
      unselectedBorderColor: theme.dividerColor.withAlpha(30),
      buttonMargin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      
      // Dynamic Generation from Category Model
      tabs: categories.map((category) {
        return Tab(
          height: 40,
          icon: Icon(
            category.icon,
            size: 16,
          ),
          iconMargin: const EdgeInsetsDirectional.only(end: 8),
          text: category.getTitle(context),
        );
      }).toList(),
    ));
  }
}
