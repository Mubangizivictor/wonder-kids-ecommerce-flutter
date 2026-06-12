import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:ecom/core/theme/app_colors.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductModel product;
  final String currency;
  final String languageCode;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.currency,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Rating Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.category.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      LucideIcons.star,
                      size: 14,
                      color: index < product.rating.floor()
                          ? AppColors.rating
                          : isDark ? AppColors.onSurfaceDark10 : AppColors.onSurfaceLight10,
                    );
                  }),
                  const SizedBox(width: 6),
                  Text(
                    '${product.rating}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${product.reviewCount} reviews)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.onSurfaceDark60 : AppColors.onSurfaceLight60,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Product Title
          Text(
            product.getLocalizedTitle(languageCode),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Price and Discounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                product.getFormattedPrice(currency),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (product.isOnSale) ...[
                const SizedBox(width: 10),
                Text(
                  product.getFormattedOriginalPrice(currency),
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: isDark ? AppColors.onSurfaceDark40 : AppColors.onSurfaceLight40,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Save ${product.discountPercentage}',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Inclusive of all taxes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.onSurfaceDark60 : AppColors.onSurfaceLight60,
            ),
          ),
        ],
      ),
    );
  }
}
