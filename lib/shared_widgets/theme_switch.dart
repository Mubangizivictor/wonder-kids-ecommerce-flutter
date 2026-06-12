import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';

/// A toggle button to switch between Light and Dark themes.
/// Standardized as a shared widget to be used across the app (AppBars, Settings, etc.)
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the theme provider to trigger the toggle function
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Using brand primary with low alpha for a subtle boutique background
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        tooltip: 'Toggle Theme',
        onPressed: () {
          themeProvider.toggleTheme();
        },
        // Smoothly switching between Sun and Moon icons based on current brightness
        icon: Icon(
          isDark ? LucideIcons.moon : LucideIcons.sun,
          size: 20,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
