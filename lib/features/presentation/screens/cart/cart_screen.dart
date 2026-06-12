import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myCart,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          if (cartProvider.itemCount > 0)
            IconButton(
              onPressed: () => cartProvider.clearCart(),
              icon: const Icon(LucideIcons.trash2, size: 20),
            ),
        ],
      ),
      body: cartProvider.itemCount == 0
          ? _buildEmptyState(context, theme, l10n)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.items.values.toList()[index];
                      return FadeInAnimation(
                        delay: Duration(milliseconds: 100 * index),
                        child: CartItemCard(cartItem: cartItem),
                      );
                    },
                  ),
                ),
                const CartSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.shoppingCart,
            size: 80,
            color: theme.colorScheme.primary.withAlpha(50),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.emptyCart,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.cartEmptyMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Provider.of<NavigationProvider>(context, listen: false).navigateToShop();
            },
            child: Text(l10n.startShopping),
          ),
        ],
      ),
    );
  }
}
