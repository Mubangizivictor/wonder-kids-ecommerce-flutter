import 'package:ecom/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/shared_widgets/custom_elevated_button.dart';
import 'package:ecom/shared_widgets/custom_outline_button.dart';

class OrderItemCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String status;
  final double amount;
  final int itemsCount;
  final List<String> imageUrls;

  final VoidCallback? onDetailsTap;

  const OrderItemCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.amount,
    required this.itemsCount,
    this.imageUrls = const [],
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDelivered = status.toLowerCase() == 'delivered';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightBlack : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0x1F000000) : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER #$orderId',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.gold : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.onSurfaceDark.withValues(alpha: 0.6) : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(theme, isDark, AppColors.gold, status, isDelivered),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              height: 1, 
              color: isDark ? const Color(0x14000000) : theme.dividerColor,
            ),
          ),
          Row(
            children: [
              if (imageUrls.isNotEmpty) _buildProductImage(imageUrls[0], theme, isDark),
              const SizedBox(width: 12),
              if (imageUrls.length > 1) _buildProductImage(imageUrls[1], theme, isDark),
              const SizedBox(width: 12),
              if (itemsCount > 2)
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x14D4AF37) : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '+${itemsCount - 2}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.gold : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (imageUrls.isEmpty) _buildImagePlaceholder(theme, isDark, AppColors.gold),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1,
                      color: isDark ? AppColors.onSurfaceDark.withValues(alpha: 0.5) : theme.textTheme.labelSmall?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    'UGX ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gold : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomOutlineButton(
                  onPressed: onDetailsTap ?? () {},
                  text: 'Details',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: () {},
                  text: 'Reorder',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isDark, Color gold, String status, bool isDelivered) {
    final color = isDelivered ? (isDark ? const Color(0xFF4DB6AC) : Colors.teal) : (isDark ? gold : theme.colorScheme.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildProductImage(String url, ThemeData theme, bool isDark) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0x14000000) : theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(theme, isDark, AppColors.gold),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme, bool isDark, Color gold) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? const Color(0x66000000) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0x14000000) : theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Icon(LucideIcons.package, size: 22, color: isDark ? const Color(0x66D4AF37) : theme.colorScheme.primary.withValues(alpha: 0.4)),
    );
  }
}
