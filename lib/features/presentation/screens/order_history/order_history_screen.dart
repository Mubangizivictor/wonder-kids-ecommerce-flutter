import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/providers/order_provider.dart';
import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:ecom/features/presentation/screens/order_history/order_details_screen.dart';
import 'package:ecom/features/presentation/screens/product/widgets/product_card_vertical.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'widgets/order_item_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.uid;
      if (userId != null) {
        context.read<OrderProvider>().startUserOrderListener(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.userOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return OrderItemCard(
                            orderId: order.id.startsWith('ORD-') ? order.id.substring(4, 9) : order.id.substring(0, 5),
                            date: "${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}",
                            status: order.status.name,
                            amount: order.totalAmount,
                            itemsCount: order.items.length,
                            imageUrls: order.items.map((item) => item.product.imgUrl).toList(),
                            onDetailsTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(order: order),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      _buildRelatedProducts(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products.take(10).toList();

    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Picked for You',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320, // Increased height to match ProductCardVertical requirements
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: SizedBox(
                  width: 160,
                  child: ProductCardVertical(product: products[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageOpen, size: 64, color: Colors.grey.withAlpha(50)),
          const SizedBox(height: 16),
          const Text('No orders yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your purchases will appear here.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
