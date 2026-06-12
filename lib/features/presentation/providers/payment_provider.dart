import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/features/domain/models/cart_item_model.dart';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:ecom/features/domain/models/payment_method_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<PaymentMethodModel> _savedMethods = [];

  final List<OrderModel> _orders = [];

  List<PaymentMethodModel> get savedMethods => _savedMethods;
  List<OrderModel> get orders => _orders;

  void addPaymentMethod(PaymentMethodModel method) {
    _savedMethods.add(method);
    notifyListeners();
  }

  void deletePaymentMethod(String id) {
    _savedMethods.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<bool> processPayment({
    required List<CartItemModel> items,
    required double total,
    required PaymentMethodModel method,
    String? address,
    String? userId,
    String? receiptImageUrl,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // Save to Firestore for Admin to see
      await _firestore.collection('orders').doc(orderId).set({
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'totalAmount': total,
        'orderDate': FieldValue.serverTimestamp(),
        'status': OrderStatus.pending.name,
        'paymentMethod': method.title,
        'shippingAddress': address ?? 'Kampala, Uganda - 123 Nakasero Rd',
        'receiptImageUrl': receiptImageUrl,
        'trackingSteps': [
          {
            'title': 'Order Placed',
            'description': 'Your order has been placed successfully.',
            'timestamp': Timestamp.now(),
            'isCompleted': true,
          }
        ],
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return false;
    }
  }
}
