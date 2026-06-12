import 'package:flutter/material.dart';

/// A reusable outlined button that respects the global theme.
/// Often used for "Secondary" or "Dismissive" actions in the luxury UI.
class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? borderColor;
  final double? width;

  const CustomOutlineButton({
    required this.onPressed,
    required this.text,
    this.borderColor,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          // FIX: Border color uses brand gold with slightly reduced alpha if not specified
          side: BorderSide(
            color: borderColor ?? theme.colorScheme.primary.withAlpha(150),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
