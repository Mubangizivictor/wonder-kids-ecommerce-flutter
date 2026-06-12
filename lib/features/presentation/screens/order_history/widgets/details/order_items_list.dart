import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/providers/locale_provider.dart';
import '../../../../../domain/models/order_model.dart';

class OrderItemsList extends StatelessWidget {
  final OrderModel order;

  const OrderItemsList({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final languageCode = localeProvider.locale.languageCode;

    return Column(
      children: order.items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imgUrl, 
                width: 60, 
                height: 60, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.withAlpha(30),
                  child: const Icon(LucideIcons.image, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.getLocalizedTitle(languageCode),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Qty: ${item.quantity}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'UGX ${(item.product.price * item.quantity).toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
