import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductDeliveryInfo extends StatelessWidget {
  const ProductDeliveryInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(context, LucideIcons.truck, 'FREE Delivery', 'on orders over UGX 100,000'),
          const SizedBox(height: 12),
          _buildInfoRow(context, LucideIcons.shieldCheck, 'Authentic Product', '100% Guaranteed'),
          const SizedBox(height: 12),
          _buildInfoRow(context, LucideIcons.refreshCw, '7 Days Return', 'Full Refund Possible'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
