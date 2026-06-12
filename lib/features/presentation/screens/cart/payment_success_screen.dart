import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:ecom/features/presentation/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/models/notification_model.dart';
import '../order_history/order_history_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger notification on success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().addNotification(
        title: 'Order Successful',
        subtitle: 'Your order #UG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)} has been placed.',
        type: NotificationType.order,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Animation (using a placeholder icon if Lottie isn't ready, but I see Lottie in pubspec)
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.checkCircle2,
                    color: Colors.green,
                    size: 100,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your order has been placed successfully. You can track its progress in the Order History section.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  context.read<NavigationProvider>().setIndex(0); // Go home
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // 1. Switch tab to Profile (index 4)
                  context.read<NavigationProvider>().setIndex(4);
                  
                  // 2. Push Order History and remove all intermediate screens until RootScreen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                    (route) => route.isFirst,
                  );
                },
                child: const Text('View Order History', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
