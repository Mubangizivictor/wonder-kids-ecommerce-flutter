import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';

/// A premium shopping cart icon button with a real-time count badge.
/// Styled with a subtle brand background for consistency across headers.
class CartIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const CartIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: 'Shopping Cart',
            onPressed: onTap ?? () {},
            icon: Icon(
              LucideIcons.shoppingBag, // Switched to bag for a more "luxury boutique" feel
              size: 20, 
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        PositionedDirectional(
          top: 4,
          end: 4,
          child: Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.itemCount == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
