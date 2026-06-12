import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/features/domain/models/cart_item_model.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderTrackingStep {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  OrderTrackingStep({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'isCompleted': isCompleted,
    };
  }

  factory OrderTrackingStep.fromMap(Map<String, dynamic> map) {
    DateTime date;
    if (map['timestamp'] is Timestamp) {
      date = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is DateTime) {
      date = map['timestamp'];
    } else {
      date = DateTime.now();
    }
    return OrderTrackingStep(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: date,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String paymentMethod;
  final String shippingAddress;
  final List<OrderTrackingStep> trackingSteps;
  final String? receiptImageUrl;
  final String? userId;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.trackingSteps,
    this.receiptImageUrl,
    this.userId,
  });

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? paymentMethod,
    String? shippingAddress,
    List<OrderTrackingStep>? trackingSteps,
    String? receiptImageUrl,
    String? userId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingSteps: trackingSteps ?? this.trackingSteps,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'trackingSteps': trackingSteps.map((x) => x.toMap()).toList(),
      'receiptImageUrl': receiptImageUrl,
      'userId': userId,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime date;
    if (map['orderDate'] is Timestamp) {
      date = (map['orderDate'] as Timestamp).toDate();
    } else if (map['orderDate'] is DateTime) {
      date = map['orderDate'];
    } else {
      date = DateTime.now();
    }

    return OrderModel(
      id: docId,
      items: (map['items'] as List? ?? [])
          .map((x) => CartItemModel.fromMap(x as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] as num? ?? 0).toDouble(),
      orderDate: date,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] ?? '',
      shippingAddress: map['shippingAddress'] ?? '',
      trackingSteps: (map['trackingSteps'] as List? ?? [])
          .map((x) => OrderTrackingStep.fromMap(x as Map<String, dynamic>))
          .toList(),
      receiptImageUrl: map['receiptImageUrl'],
      userId: map['userId'],
    );
  }
}
