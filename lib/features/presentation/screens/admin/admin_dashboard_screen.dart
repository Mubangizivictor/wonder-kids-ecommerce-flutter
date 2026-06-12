import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'widgets/admin_stats_view.dart';
import 'widgets/admin_orders_view.dart';
import 'widgets/admin_products_view.dart';
import 'widgets/admin_categories_view.dart';
import 'widgets/admin_notifications_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const AdminStatsView(),
    const AdminOrdersView(),
    const AdminProductsView(),
    const AdminNotificationsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel', 
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.logOut),
            tooltip: 'Exit',
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircleAvatar(
                  radius: 30,
                  child: Icon(LucideIcons.userCheck),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(LucideIcons.layoutDashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.shoppingCart),
                  label: Text('Orders'),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.package),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.bell),
                  label: Text('Notifications'),
                ),
              ],
            ),
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(30),
              child: _views[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Stats'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.shoppingCart), label: 'Orders'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.package), label: 'Products'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.bell), label: 'Alerts'),
              ],
            )
          : null,
    );
  }
}
