import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/screens/auth/login_screen.dart';
import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:ecom/features/presentation/providers/wishlist_provider.dart';
import 'package:ecom/features/presentation/providers/settings_provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../product_details_screen.dart';

class ProductCardHorizontal extends StatelessWidget {
  final ProductModel product;

  const ProductCardHorizontal({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currency;
    final isInCart = cartProvider.isInCart(product.id);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isFavorite(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Image ─────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 110,
                      height: 110,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Hero(
                        tag: 'product_image_${product.id}',
                        child: Image.network(
                          product.imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            LucideIcons.image,
                            size: 30,
                            color: theme.colorScheme.primary.withAlpha(80),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.isOnSale)
                    PositionedDirectional(
                      top: 6,
                      start: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.discountPercentage,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // ── Details ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (!authProvider.isAuthenticated) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                              return;
                            }
                            wishlistProvider.toggleWishlist(product);
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted ? LucideIcons.heart : LucideIcons.heart,
                              size: 16,
                              color: isWishlisted ? Colors.redAccent : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.star, size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          product.getFormattedPrice(currency),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 6),
                          Text(
                            product.getFormattedOriginalPrice(currency),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Add to cart button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: product.isInStock ? () {
                          if (!authProvider.isAuthenticated) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            return;
                          }
                          if (isInCart) {
                            Provider.of<NavigationProvider>(context, listen: false).setIndex(3);
                            Navigator.popUntil(context, (route) => route.isFirst);
                          } else {
                            cartProvider.addItem(product);
                          }
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(
                          isInCart ? l10n.viewCart.toUpperCase() : l10n.addToCart.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
