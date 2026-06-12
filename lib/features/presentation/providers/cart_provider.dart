import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:ecom/features/domain/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  static const double freeDeliveryThreshold = 100000.0;
  static const double defaultDeliveryFee = 15000.0;

  final Box<CartItemModel> _cartBox = Hive.box<CartItemModel>('cart_box');

  Map<String, CartItemModel> get items {
    final Map<String, CartItemModel> itemsMap = {};
    for (var key in _cartBox.keys) {
      itemsMap[key.toString()] = _cartBox.get(key)!;
    }
    return itemsMap;
  }

  int get itemCount => _cartBox.length;

  bool isInCart(String productId) => _cartBox.containsKey(productId);

  double get totalAmount {
    var total = 0.0;
    for (var item in _cartBox.values) {
      total += item.product.discountedPrice * item.quantity;
    }
    return total;
  }

  double get subtotal => totalAmount;

  double get deliveryFee => subtotal >= freeDeliveryThreshold ? 0.0 : defaultDeliveryFee;

  double get totalWithDelivery => subtotal + deliveryFee;

  void addItem(ProductModel product, {int quantity = 1, String? color, String? size}) {
    if (_cartBox.containsKey(product.id)) {
      final existingItem = _cartBox.get(product.id)!;
      _cartBox.put(
        product.id,
        CartItemModel(
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          selectedColor: color ?? existingItem.selectedColor,
          selectedSize: size ?? existingItem.selectedSize,
        ),
      );
    } else {
      _cartBox.put(
        product.id,
        CartItemModel(
          product: product,
          quantity: quantity,
          selectedColor: color,
          selectedSize: size,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartBox.delete(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_cartBox.containsKey(productId)) return;

    final existingItem = _cartBox.get(productId)!;
    if (existingItem.quantity > 1) {
      _cartBox.put(
        productId,
        CartItemModel(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
          selectedColor: existingItem.selectedColor,
          selectedSize: existingItem.selectedSize,
        ),
      );
    } else {
      _cartBox.delete(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartBox.clear();
    notifyListeners();
  }
}
