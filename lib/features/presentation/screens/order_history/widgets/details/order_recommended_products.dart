import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../../domain/models/order_model.dart';
import '../../../product/widgets/product_card_vertical.dart';

class OrderRecommendedProducts extends StatelessWidget {
  final OrderModel order;

  const OrderRecommendedProducts({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    // Suggest products from similar categories as ordered items
    final categories = order.items.map((i) => i.product.category).toSet();
    final relatedProducts = productProvider.products
        .where((p) => categories.contains(p.category) && !order.items.any((oi) => oi.product.id == p.id))
        .take(6)
        .toList();

    if (relatedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended for You',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to shop or category
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 340, // Sufficient height for ProductCardVertical to avoid overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: SizedBox(
                  width: 160,
                  child: ProductCardVertical(product: relatedProducts[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
