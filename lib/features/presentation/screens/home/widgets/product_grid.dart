import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:ecom/features/presentation/providers/settings_provider.dart';
import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import '../../../../domain/models/category_model.dart'; // Category definition
import '../../product/widgets/product_card_vertical.dart'; // The UI card component
import '../../product/widgets/product_card_horizontal.dart';

class ProductGrid extends StatelessWidget {
  /// The category of products to display.
  final CategoryModel category;

  /// Whether to display products in a grid or a list view.
  final bool isGridView;

  /// Current search query for filtering products.
  final String searchQuery;

  /// Selected price range for filtering.
  final String priceRange;

  /// Sort criteria index.
  final int sortIndex;

  const ProductGrid({
    super.key,
    required this.category,
    this.isGridView = true,
    this.searchQuery = '',
    this.priceRange = 'All',
    this.sortIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayProducts = productProvider.getFilteredProducts(
      categoryTitle: category.titleKey,
      searchQuery: searchQuery,
      priceRange: priceRange,
      sortIndex: sortIndex,
      currency: settingsProvider.currency,
    );

    if (displayProducts.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noProductsFound,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (!isGridView) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          return FadeInAnimation(
            delay: Duration(milliseconds: 100 * index),
            child: ProductCardHorizontal(product: product),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        return FadeInAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: ProductCardVertical(product: product),
        );
      },
    );
  }
}
