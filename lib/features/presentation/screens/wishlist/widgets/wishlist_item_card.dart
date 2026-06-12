import 'package:ecom/features/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/wishlist_provider.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:ecom/shared_widgets/wishlist_icon.dart';

import '../../product/product_details_screen.dart';

class WishlistItemCard extends StatelessWidget {
  final ProductModel product;

  const WishlistItemCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currency;
    final isInCart = cartProvider.isInCart(product.id);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark 
              ? theme.colorScheme.primary.withAlpha(30)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.light ? 10 : 40),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    product.imgUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.primary.withAlpha(10),
                      child: Icon(LucideIcons.image, color: theme.colorScheme.primary.withAlpha(100)),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: WishlistIcon(
                    isSelected: true,
                    onPressed: () => wishlistProvider.toggleWishlist(product),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.getLocalizedTitle(languageCode),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.getFormattedPrice(currency),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isInCart) {
                            context.read<NavigationProvider>().setIndex(3);
                            Navigator.popUntil(context, (route) => route.isFirst);
                          } else {
                            cartProvider.addItem(product);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isInCart ? l10n.view : l10n.addToCart,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // View Details Icon Button
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        icon: Icon(LucideIcons.eye, size: 18, color: theme.colorScheme.primary),
                        visualDensity: VisualDensity.compact,
                        tooltip: l10n.viewDetails,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
