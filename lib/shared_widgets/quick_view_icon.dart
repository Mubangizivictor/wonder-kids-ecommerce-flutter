import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A button that triggers a "Quick View" modal for a product.
class QuickViewIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const QuickViewIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        tooltip: 'Quick View',
        onPressed: onTap ?? () {},
        icon: Icon(
          LucideIcons.eye, 
          size: 20, 
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
