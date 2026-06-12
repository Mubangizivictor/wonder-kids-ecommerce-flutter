import 'package:ecom/core/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/order_provider.dart';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import 'package:ecom/core/services/pdf_service.dart';

class AdminOrdersView extends StatelessWidget {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'Order Management',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton.filled(
                  onPressed: () => orderProvider.fetchAllOrders(),
                  icon: const Icon(LucideIcons.refreshCcw, size: 20),
                  tooltip: 'Refresh Orders',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: orderProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orderProvider.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.shieldAlert, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Permission Denied',
                                style: theme.textTheme.titleLarge?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Check your Firestore Security Rules.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => orderProvider.fetchAllOrders(),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : orderProvider.allOrders.isEmpty
                          ? const Center(child: Text('No orders found.'))
                          : _buildOrdersTable(context, orderProvider.allOrders, localeProvider.locale.languageCode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTable(BuildContext context, List<OrderModel> orders, String languageCode) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Age')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: orders.map((order) {
              final age = DateTime.now().difference(order.orderDate);
              String ageText;
              if (age.inDays > 0) {
                ageText = '${age.inDays}d ago';
              } else if (age.inHours > 0) {
                ageText = '${age.inHours}h ago';
              } else {
                ageText = '${age.inMinutes}m ago';
              }

              return DataRow(cells: [
                DataCell(Text('#${order.id.substring(0, 8)}...')),
                DataCell(Text(DateFormat('MMM dd, yyyy').format(order.orderDate))),
                DataCell(Text(ageText, style: TextStyle(
                  color: age.inDays > 3 && order.status == OrderStatus.pending ? Colors.red : null,
                  fontWeight: age.inDays > 3 && order.status == OrderStatus.pending ? FontWeight.bold : null,
                ))),
                DataCell(Text(order.shippingAddress)), // Placeholder for customer name
                DataCell(Text('UGX ${NumberFormat('#,###').format(order.totalAmount)}')),
                DataCell(_buildStatusBadge(context, order.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (order.receiptImageUrl != null)
                        IconButton(
                          icon: const Icon(LucideIcons.image, size: 18, color: Colors.blue),
                          onPressed: () => _showReceiptDialog(context, order.receiptImageUrl!),
                          tooltip: 'View Receipt',
                        ),
                      IconButton(
                        icon: const Icon(LucideIcons.printer, size: 18, color: Colors.orange),
                        onPressed: () => PdfService.generateAndPrintReceipt(order),
                        tooltip: 'Print Receipt',
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.eye, size: 18),
                        onPressed: () => _showOrderDetailsDialog(context, order, languageCode),
                      ),
                      PopupMenuButton<OrderStatus>(
                        icon: const Icon(LucideIcons.moreVertical, size: 18),
                        onSelected: (status) => context.read<OrderProvider>().updateOrderStatus(order.id, status),
                        itemBuilder: (context) => OrderStatus.values.map((status) {
                          return PopupMenuItem(
                            value: status,
                            child: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending: color = Colors.orange; break;
      case OrderStatus.processing: color = Colors.blue; break;
      case OrderStatus.shipped: color = Colors.purple; break;
      case OrderStatus.delivered: color = Colors.green; break;
      case OrderStatus.cancelled: color = Colors.red; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Payment Receipt'),
              leading: const CloseButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrderModel order, String languageCode) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Details', style: theme.textTheme.headlineSmall),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => PdfService.generateAndPrintReceipt(order),
                          icon: const Icon(LucideIcons.printer),
                          tooltip: 'Print Invoice',
                        ),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoRow('Order ID', order.id),
                _buildInfoRow('Customer ID', order.userId ?? 'Guest'),
                _buildInfoRow('Date', DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate)),
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    _buildStatusBadge(context, order.status),
                    const SizedBox(width: 8),
                    PopupMenuButton<OrderStatus>(
                      icon: const Icon(LucideIcons.edit3, size: 16),
                      onSelected: (status) {
                        context.read<OrderProvider>().updateOrderStatus(order.id, status);
                        Navigator.pop(context);
                      },
                      itemBuilder: (context) => OrderStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Payment', order.paymentMethod),
                _buildInfoRow('Address', order.shippingAddress),
                const SizedBox(height: 24),
                Text('Items', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.product.getLocalizedTitle(languageCode)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text('UGX ${NumberFormat('#,###').format(item.product.discountedPrice * item.quantity)}'),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('UGX ${NumberFormat('#,###').format(order.totalAmount)}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tracking History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showAddTrackingDialog(context, order.id),
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Add Step'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (order.trackingSteps.isEmpty)
                  const Text('No tracking updates yet.')
                else
                  ...order.trackingSteps.map((step) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(step.isCompleted ? LucideIcons.circleCheck : LucideIcons.circle,
                            color: step.isCompleted ? Colors.green : Colors.grey, size: 16),
                        title: Text(step.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text('${step.description}\n${DateFormat('MMM dd, HH:mm').format(step.timestamp)}',
                            style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddTrackingDialog(BuildContext context, String orderId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tracking Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Status Title (e.g. Shipped)')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<OrderProvider>().addTrackingStep(
                      orderId,
                      OrderTrackingStep(
                        title: titleController.text,
                        description: descController.text,
                        timestamp: DateTime.now(),
                        isCompleted: true,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
