import 'package:ecom/features/domain/models/payment_method_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentMethodTile extends StatelessWidget {
  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PaymentMethodTile({
    super.key,
    required this.method,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withAlpha(50),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? theme.colorScheme.primary.withAlpha(10) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getBrandColor(method.type).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                method.icon,
                color: _getBrandColor(method.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.checkCircle2,
                color: theme.colorScheme.primary,
              )
            else if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
              )
            else
              const Icon(
                LucideIcons.chevronRight,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Color _getBrandColor(PaymentType type) {
    switch (type) {
      case PaymentType.mtn:
        return const Color(0xFFFFCC00); // MTN Yellow
      case PaymentType.airtel:
        return const Color(0xFFFF0000); // Airtel Red
      case PaymentType.card:
      case PaymentType.stripe:
        return Colors.blueAccent;
      case PaymentType.cash:
        return Colors.teal;
    }
  }
}
