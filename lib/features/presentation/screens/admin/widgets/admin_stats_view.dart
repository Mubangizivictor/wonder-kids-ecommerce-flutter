// ignore_for_file: unused_local_variable, unused_element

import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/order_provider.dart';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../providers/category_provider.dart';

class AdminStatsView extends StatelessWidget {
  const AdminStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final theme = Theme.of(context);
    final orders = orderProvider.allOrders;
    final products = productProvider.products;

    // Calculations
    final totalRevenue = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    // final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
    final deliveredOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;

    // New Metrics for MVP
    final awaitingVerification = orders
        .where(
          (o) => o.receiptImageUrl != null && o.status == OrderStatus.pending,
        )
        .length;

    final outOfStockCount = products.where((p) => p.stockStatus).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Business Overview',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    orderProvider.fetchAllOrders();
                    productProvider.fetchProducts();
                  },
                  icon: const Icon(LucideIcons.refreshCcw),
                  tooltip: 'Refresh Stats',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Primary Stats Grid
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200
                  ? 4
                  : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              children: [
                _buildStatCard(
                  context,
                  'Total Revenue',
                  'UGX ${NumberFormat('#,###').format(totalRevenue)}',
                  LucideIcons.banknote,
                  Colors.green,
                  subtitle: '+12% from last month',
                ),
                _buildStatCard(
                  context,
                  'Total Orders',
                  orders.length.toString(),
                  LucideIcons.shoppingBag,
                  Colors.blue,
                  subtitle:
                      '${orders.where((o) => o.orderDate.day == DateTime.now().day).length} today',
                ),
                _buildStatCard(
                  context,
                  'Active Shipments',
                  orders
                      .where(
                        (o) =>
                            o.status == OrderStatus.shipped ||
                            o.status == OrderStatus.processing,
                      )
                      .length
                      .toString(),
                  LucideIcons.truck,
                  Colors.purple,
                ),
                _buildStatCard(
                  context,
                  'Completed Sales',
                  deliveredOrders.toString(),
                  LucideIcons.checkCircle,
                  theme.colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (products.isEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Setup Store',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await Provider.of<CategoryProvider>(
                          context,
                          listen: false,
                        ).seedCategories();
                        await productProvider.seedProducts();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Store data seeded successfully!'),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error seeding: $e')),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.database, size: 16),
                    label: const Text('Setup Store Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Recent Orders List (Mini)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // This is usually handled by switching the tab in AdminDashboard
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor.withAlpha(50)),
              ),
              child: orders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: Text('No recent activity found.')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length > 5 ? 5 : orders.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer
                                .withAlpha(100),
                            child: Icon(
                              order.receiptImageUrl != null
                                  ? LucideIcons.receipt
                                  : LucideIcons.shoppingCart,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            'Order #${order.id.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'MMM dd • HH:mm',
                            ).format(order.orderDate),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'UGX ${NumberFormat('#,###').format(order.totalAmount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order.status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 0,
      color: color.withAlpha(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: color),
        title: Text(
          '$count $title',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
