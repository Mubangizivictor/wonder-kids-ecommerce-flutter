// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _newArrivals = true;
  bool _newsletter = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection(
              context,
              'Activity Notifications',
              [
                _buildSwitchTile(
                  'Order Updates', 
                  'Notifications about your order status and shipping updates', 
                  _orderUpdates, 
                  (v) => setState(() => _orderUpdates = v),
                  LucideIcons.package,
                ),
                const Divider(height: 1, indent: 60),
                _buildSwitchTile(
                  'Price Drops', 
                  'Alerts when items in your wishlist go on sale', 
                  true, 
                  (v) {},
                  LucideIcons.trendingDown,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildNotificationSection(
              context,
              'Marketing & Promotions',
              [
                _buildSwitchTile(
                  'Promotions', 
                  'Exclusive coupons, flash sales and special offers', 
                  _promotions, 
                  (v) => setState(() => _promotions = v),
                  LucideIcons.tag,
                ),
                const Divider(height: 1, indent: 60),
                _buildSwitchTile(
                  'New Arrivals', 
                  'Weekly updates on our new products', 
                  _newArrivals, 
                  (v) => setState(() => _newArrivals = v),
                  LucideIcons.sparkles,
                ),
                const Divider(height: 1, indent: 60),
                _buildSwitchTile(
                  'Newsletter', 
                  'Our monthly kids style and wellness guide', 
                  _newsletter, 
                  (v) => setState(() => _newsletter = v),
                  LucideIcons.mail,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Reset to Default Settings',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 16),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon, 
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title, 
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
              height: 1.3,
            ),
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
          activeTrackColor: theme.colorScheme.primary.withAlpha(100),
        ),
      ),
    );
  }
}
