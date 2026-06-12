import 'package:flutter/material.dart';

/// A circular button used for social authentication (Google, Apple, etc.)
/// Design follows the Wonder Kids theme with adaptive background colors.
class SocialAuthButton extends StatelessWidget {
  final String iconUrl;
  final VoidCallback onTap;

  const SocialAuthButton({
    super.key,
    required this.iconUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          // FIX: Adaptive background color to avoid "theme leaks"
          color: isDark ? theme.colorScheme.surface : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              // FIX: Subtle shadow that adapts to brightness
              color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Image.network(
          iconUrl,
          fit: BoxFit.contain,
          // Placeholder for when the image fails to load
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.security, 
            size: 20, 
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
