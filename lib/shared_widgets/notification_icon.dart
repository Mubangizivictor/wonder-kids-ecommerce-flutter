import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/providers/notification_provider.dart';
import 'package:ecom/features/presentation/screens/notifications/notifications_inbox_screen.dart';
import 'package:ecom/features/presentation/screens/auth/login_screen.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// A notification icon with a badge, styled for the luxury theme.
class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final unreadCount = authProvider.isAuthenticated ? notificationProvider.unreadCount : 0;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              if (authProvider.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationInboxScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            icon: Icon(
              LucideIcons.bell, 
              size: 20, 
              color: theme.colorScheme.primary
            ),
          ),
          // Notification Badge
          if (unreadCount > 0)
            PositionedDirectional(
              end: 10,
              top: 10,
              child: Container(
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface, 
                    width: 1.5,
                  ),
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
