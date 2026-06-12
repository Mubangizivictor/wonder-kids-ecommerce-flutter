import 'package:ecom/core/theme/app_colors.dart';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:ecom/features/presentation/screens/order_history/widgets/details/order_items_list.dart';
import 'package:ecom/features/presentation/screens/order_history/widgets/details/order_payment_summary.dart';
import 'package:ecom/features/presentation/screens/order_history/widgets/details/order_recommended_products.dart';
import 'package:ecom/features/presentation/screens/order_history/widgets/details/order_tracking_stepper.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #${order.id.split('-').last.substring(0, 5)}'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              'Delivery Status',
              OrderTrackingStepper(order: order),
            ),
            const SizedBox(height: 32),
            _buildReceiptImage(theme, isDark),
            _buildSection(
              theme,
              'Shipping Address',
              _buildAddressInfo(theme, order.shippingAddress, isDark),
            ),
            const SizedBox(height: 32),
            _buildSection(
              theme,
              'Order Items',
              OrderItemsList(order: order),
            ),
            const SizedBox(height: 32),
            _buildSection(
              theme,
              'Payment Information',
              OrderPaymentSummary(order: order),
            ),
            const SizedBox(height: 40),
            OrderRecommendedProducts(order: order),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildReceiptImage(ThemeData theme, bool isDark) {
    if (order.receiptImageUrl == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          theme,
          'Payment Receipt',
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 50 : 10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  // Potential fullscreen view logic
                },
                child: Image.network(
                  order.receiptImageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: isDark ? AppColors.surfaceDark : Colors.grey.withAlpha(30),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.imageOff, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Failed to load receipt', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAddressInfo(ThemeData theme, String address, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.mapPin, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
