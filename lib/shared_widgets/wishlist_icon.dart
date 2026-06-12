import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A wishlist icon button used in product details and list items.
class WishlistIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isSelected;

  const WishlistIcon({
    super.key, 
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light 
            ? Colors.white.withAlpha(220) 
            : Colors.black.withAlpha(150),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        tooltip: isSelected ? 'Remove from Wishlist' : 'Add to Wishlist',
        onPressed: onPressed ?? () {},
        icon: Icon(
          isSelected ? Icons.favorite : Icons.favorite_border,
          size: 20, 
          color: isSelected 
              ? const Color(0xFFF06292) // Premium Pink
              : (theme.brightness == Brightness.light ? Colors.black87 : Colors.white70),
        ),
      ),
    );
  }
}
