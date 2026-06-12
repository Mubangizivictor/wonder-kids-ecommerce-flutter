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
import 'package:ecom/features/presentation/screens/cart/checkout_screen.dart';
import 'package:ecom/shared_widgets/wishlist_icon.dart';
import '../../../../../l10n/app_localizations.dart';
import '../product_details_screen.dart';

/// A premium vertical product card designed for the "Luxury Ugandan" boutique aesthetic.
/// Features adaptive theme support and standardized brand colors.
class ProductCardVertical extends StatelessWidget {
  final ProductModel product;

  const ProductCardVertical({
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
    final languageCode = Localizations.localeOf(context).languageCode;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image Section ──────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: Image.network(
                        product.imgUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.primary.withAlpha(10),
                          child: Icon(LucideIcons.image, color: theme.colorScheme.primary.withAlpha(100)),
                        ),
                      ),
                    ),
                  ),

                  // Wishlist Button
                  PositionedDirectional(
                    top: 10,
                    end: 10,
                    child: WishlistIcon(
                      isSelected: isWishlisted,
                      onPressed: () {
                        if (!authProvider.isAuthenticated) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          return;
                        }
                        wishlistProvider.toggleWishlist(product);
                      },
                    ),
                  ),

                  // Discount Badge
                  if (product.isOnSale)
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
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

                  // Out of Stock Overlay
                  if (product.isInStock == false)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                        ),
                        child: Center(
                          child: Text(
                            l10n.soldOut,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Details Section ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    product.getLocalizedTitle(languageCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 1),

                  // Description (Max 1 line to save space and keep it clean)
                  Text(
                    product.getLocalizedDescription(languageCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 4),

                  // Rating and Reviews
                  Row(
                    children: [
                      const Icon(LucideIcons.star, size: 10, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '(${product.reviewCount})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(100),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.getFormattedPrice(currency),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.getFormattedOriginalPrice(currency),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withAlpha(100),
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Action Row
                  Row(
                    children: [
                      // Add to Cart / View in Cart
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 32,
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              isInCart ? l10n.viewCart.toUpperCase() : l10n.addToCart.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // View Details Icon Button
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
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
                          icon: Icon(LucideIcons.eye, size: 16, color: theme.colorScheme.primary),
                          tooltip: l10n.viewDetails,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
