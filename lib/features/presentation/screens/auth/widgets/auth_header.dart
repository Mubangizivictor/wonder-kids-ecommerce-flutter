import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    
    return Column(
      children: [
        // App Logo
        Image.asset(
          'assets/logos/wonder-kids-icon.png',
          height: 100,
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withAlpha(isDark ? 150 : 180),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
