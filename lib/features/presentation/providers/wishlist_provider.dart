import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecom/features/domain/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final Box<ProductModel> _wishlistBox = Hive.box<ProductModel>('wishlist_box');

  Map<String, ProductModel> get items {
    final Map<String, ProductModel> itemsMap = {};
    for (var key in _wishlistBox.keys) {
      itemsMap[key.toString()] = _wishlistBox.get(key)!;
    }
    return itemsMap;
  }

  int get itemCount => _wishlistBox.length;

  bool isFavorite(String productId) {
    return _wishlistBox.containsKey(productId);
  }

  void toggleWishlist(ProductModel product) {
    if (_wishlistBox.containsKey(product.id)) {
      _wishlistBox.delete(product.id);
    } else {
      _wishlistBox.put(product.id, product);
    }
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistBox.clear();
    notifyListeners();
  }
}
