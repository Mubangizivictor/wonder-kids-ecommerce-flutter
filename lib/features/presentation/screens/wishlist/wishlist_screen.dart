import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/shared_widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/wishlist_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'widgets/wishlist_item_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistItems = wishlistProvider.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myWishlist,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          if (wishlistItems.isNotEmpty)
            IconButton(
              onPressed: () => wishlistProvider.clearWishlist(),
              icon: const Icon(LucideIcons.trash2, size: 20),
            ),
        ],
      ),
      body: wishlistItems.isEmpty 
          ? _buildEmptyState(context, theme, l10n)
          : Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.itemsCount(wishlistItems.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final product = wishlistItems[index];
                return WishlistItemCard(
                  product: product,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.heart,
                size: 80,
                color: theme.colorScheme.primary.withAlpha(150),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.emptyWishlist,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.wishlistEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 40),
            CustomElevatedButton(
              text: l10n.startExploring,
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false).navigateToShop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
