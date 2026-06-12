import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:ecom/features/domain/models/cart_item_model.dart';
import 'package:flutter/material.dart';

import 'package:ecom/core/services/notification_service.dart';
import 'package:ecom/features/presentation/providers/notification_provider.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderModel> _allOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _userOrdersSubscription;
  List<OrderModel> _userOrders = [];

  List<OrderModel> get allOrders => _allOrders;
  List<OrderModel> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider() {
    // We don't call startOrderListener() here anymore to avoid 
    // permission errors for non-admin users on startup.
    // Instead, listeners are started based on user role/screen.
  }

  void startOrderListener() {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Removed to prevent build-phase notify errors

    _ordersSubscription?.cancel();
    _ordersSubscription = _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _allOrders = snapshot.docs.map((doc) => _mapDocToOrder(doc)).toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Orders Stream Error: $error');
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void startUserOrderListener(String userId) {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;

    _userOrdersSubscription?.cancel();
    _userOrdersSubscription = _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _userOrders = snapshot.docs.map((doc) => _mapDocToOrder(doc)).toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('User Orders Stream Error: $error');
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _userOrdersSubscription?.cancel();
    super.dispose();
  }

  // Fetch all orders (Legacy/Manual)
  Future<void> fetchAllOrders() async {
    startOrderListener(); // Restart the stream
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // 1. Optimistic Update: Update local state immediately for snappy UI
      final index = _allOrders.indexWhere((o) => o.id == orderId);
      OrderModel? order;
      if (index != -1) {
        order = _allOrders[index];
        final updatedOrder = order.copyWith(status: newStatus);
        _allOrders[index] = updatedOrder;
        notifyListeners();
      }

      final batch = _firestore.batch();
      final orderRef = _firestore.collection('orders').doc(orderId);
      
      batch.update(orderRef, {
        'status': newStatus.name,
        'trackingSteps': FieldValue.arrayUnion([
          {
            'title': 'Status Updated: ${newStatus.name.toUpperCase()}',
            'description': 'Your order status has been updated by the administrator.',
            'timestamp': Timestamp.now(),
            'isCompleted': true,
          }
        ]),
      });

      // 2. Add a notification document for the user in Firestore
      if (order != null && order.userId != null) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': order.userId,
          'title': 'Order Status Updated',
          'subtitle': 'Your order #${orderId.substring(0, 8)}... is now ${newStatus.name.toUpperCase()}.',
          'type': 'order',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      await batch.commit();

      // In a real app, this would be triggered by a Cloud Function on the server
      _notifyUserOfStatusChange(orderId, newStatus);
    } catch (e) {
      debugPrint('Error updating order status: $e');
      // If error, refresh from server to revert optimistic update
      startOrderListener();
      rethrow;
    }
  }

  // Confirm payment
  Future<void> confirmPayment(String orderId) async {
     // In a real app, you might have a paymentStatus field. 
     // For now we can move status to 'processing' as confirmation.
     await updateOrderStatus(orderId, OrderStatus.processing);
  }

  Future<void> addTrackingStep(String orderId, OrderTrackingStep step) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);
      final doc = await orderRef.get();
      final userId = doc.data()?['userId'];

      final batch = _firestore.batch();
      
      batch.update(orderRef, {
        'trackingSteps': FieldValue.arrayUnion([
          {
            'title': step.title,
            'description': step.description,
            'timestamp': Timestamp.fromDate(step.timestamp),
            'isCompleted': step.isCompleted,
          }
        ]),
      });

      if (userId != null) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userId,
          'title': 'Tracking Update: ${step.title}',
          'subtitle': step.description,
          'type': 'order',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding tracking step: $e');
      rethrow;
    }
  }

  void _notifyUserOfStatusChange(String orderId, OrderStatus status) {
    // This is a placeholder for actual FCM logic which usually happens server-side
    // For MVP, we can add it to the local NotificationProvider if we had access to it, 
    // but providers shouldn't usually depend on each other like that.
    // Instead, we print for debug. In a real scenario, a Cloud Function watches 'orders/{id}'
    debugPrint('SIMULATING PUSH NOTIFICATION: Order $orderId is now ${status.name}');
  }

  OrderModel _mapDocToOrder(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromMap(data, doc.id);
    } catch (e) {
      debugPrint('Error mapping order ${doc.id}: $e');
      // Return a dummy order instead of crashing/stopping the loop
      return OrderModel(
        id: doc.id,
        items: [],
        totalAmount: 0,
        orderDate: DateTime.now(),
        status: OrderStatus.cancelled,
        paymentMethod: 'Error',
        shippingAddress: 'Mapping Failed',
        trackingSteps: [],
      );
    }
  }
}
