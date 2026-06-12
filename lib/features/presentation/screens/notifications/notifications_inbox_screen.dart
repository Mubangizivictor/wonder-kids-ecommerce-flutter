import 'package:ecom/features/presentation/providers/notification_provider.dart';
import 'package:ecom/features/presentation/screens/profile/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'widgets/notification_tile.dart';
import 'notification_detail_screen.dart';

class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(LucideIcons.settings, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff, size: 64, color: theme.colorScheme.onSurface.withAlpha(50)),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(100)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifications.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionHeader(title: 'Recent'),
                      if (notificationProvider.unreadCount > 0)
                        TextButton(
                          onPressed: () => notificationProvider.markAllAsRead(),
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                final notification = notifications[index - 1];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(LucideIcons.checkCircle, color: theme.colorScheme.primary),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(LucideIcons.trash2, color: Colors.red),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      notificationProvider.markAsRead(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as read'), duration: Duration(seconds: 1)),
                      );
                      return false; // Don't remove the item
                    }
                    return true; // Remove the item
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      notificationProvider.removeNotification(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification deleted')),
                      );
                    }
                  },
                  child: NotificationTile(
                    title: notification.title,
                    subtitle: notification.subtitle,
                    time: notification.time,
                    icon: notification.icon,
                    isRead: notification.isRead,
                    type: notification.type,
                    onTap: () {
                      notificationProvider.markAsRead(notification.id);
                      _navigateToDetail(
                        context, 
                        notification.title, 
                        notification.type.toString().split('.').last,
                        notification.subtitle,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _navigateToDetail(BuildContext context, String title, String type, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(
          title: title,
          content: content,
          type: type,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(150),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
