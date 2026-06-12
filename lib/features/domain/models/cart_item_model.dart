import 'package:hive/hive.dart';
import 'product_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 1)
class CartItemModel {
  @HiveField(0)
  final ProductModel product;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  String? selectedColor;

  @HiveField(3)
  String? selectedSize;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  double get totalItemPrice => product.discountedPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      product: ProductModel.fromMap(map['product'] as Map<String, dynamic>),
      quantity: map['quantity'] ?? 1,
      selectedColor: map['selectedColor'],
      selectedSize: map['selectedSize'],
    );
  }
}
