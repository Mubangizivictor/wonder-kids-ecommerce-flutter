import 'package:ecom/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../domain/models/order_model.dart';

class OrderPaymentSummary extends StatelessWidget {
  final OrderModel order;

  const OrderPaymentSummary({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtotal = order.items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final deliveryFee = order.totalAmount - subtotal;

    return Container(
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
      child: Column(
        children: [
          _infoRow(theme, 'Payment Method', order.paymentMethod),
          const Divider(height: 32),
          _infoRow(theme, 'Subtotal', 'UGX ${subtotal.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}'),
          const SizedBox(height: 12),
          _infoRow(theme, 'Delivery Fee', deliveryFee <= 0 ? 'FREE' : 'UGX ${deliveryFee.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}'),
          const Divider(height: 32),
          _infoRow(
            theme, 
            'Total', 
            'UGX ${order.totalAmount.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}', 
            isBold: true,
            valueColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isBold ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(150),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value, 
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
