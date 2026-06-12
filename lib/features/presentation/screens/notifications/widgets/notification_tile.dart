import 'package:ecom/core/theme/app_colors.dart';
import 'package:ecom/features/presentation/providers/notification_provider.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool isRead;
  final NotificationType type;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    this.isRead = false,
    this.type = NotificationType.system,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? (isRead ? const Color(0x660F1115) : AppColors.midnightBlack) : (isRead ? theme.colorScheme.surface.withValues(alpha: 0.6) : theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
                ? (isRead ? const Color(0x14D4AF37) : const Color(0x33D4AF37))
                : (isRead ? AppColors.transparent : theme.colorScheme.primary.withValues(alpha: 0.1)),
            width: 1,
          ),
          boxShadow: isRead ? [] : [
            BoxShadow(
              color: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(theme, isDark, AppColors.gold),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: _getIconColor(theme, isDark, AppColors.gold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: isDark 
                                ? (isRead ? AppColors.onSurfaceDark.withValues(alpha: 0.6) : AppColors.onSurfaceDark)
                                : (isRead ? theme.colorScheme.onSurface.withValues(alpha: 0.8) : theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.gold : theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.onSurfaceDark.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.gold.withValues(alpha: 0.7) : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconColor(ThemeData theme, bool isDark, Color gold) {
    switch (type) {
      case NotificationType.order:
        return isDark ? AppColors.info : Colors.blueAccent;
      case NotificationType.promotion:
        return isDark ? AppColors.gold : theme.colorScheme.primary;
      case NotificationType.security:
        return isDark ? AppColors.warning : Colors.orangeAccent;
      case NotificationType.system:
        return isDark ? AppColors.starGrey : Colors.grey;
    }
  }

  Color _getIconBackgroundColor(ThemeData theme, bool isDark, Color gold) {
    return _getIconColor(theme, isDark, gold).withValues(alpha: 0.1);
  }
}
