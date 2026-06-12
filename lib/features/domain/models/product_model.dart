import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String imgUrl; // Keep for backward compatibility/main image
  @HiveField(4)
  final double price;
  @HiveField(5)
  final double discountedPrice;
  @HiveField(6)
  final String category;
  @HiveField(7)
  final double rating;
  @HiveField(8)
  final int reviewCount;
  @HiveField(9)
  final String? titleAr;
  @HiveField(10)
  final String? descriptionAr;
  @HiveField(11)
  final List<String>? images;
  @HiveField(12)
  final bool? isOutOfStock;
  @HiveField(13)
  final List<String>? colors;
  @HiveField(14)
  final List<String>? sizes;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imgUrl,
    required this.price,
    required this.discountedPrice,
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.titleAr,
    this.descriptionAr,
    this.images = const [],
    this.isOutOfStock = false,
    this.colors = const [],
    this.sizes = const [],
  });

  List<String> get productImages => images ?? [imgUrl];
  List<String> get productColors => colors ?? [];
  List<String> get productSizes => sizes ?? [];
  bool get stockStatus => isOutOfStock ?? false;

  String getLocalizedTitle(String languageCode) {
    if (languageCode == 'ar' && titleAr != null) return titleAr!;
    return title;
  }

  String getLocalizedDescription(String languageCode) {
    if (languageCode == 'ar' && descriptionAr != null) return descriptionAr!;
    return description;
  }

  // Currency conversion and formatting
  String getFormattedPrice(String currencyCode) {
    if (currencyCode == 'USD') {
      double usdPrice = discountedPrice / 3800;
      return '\$${usdPrice.toStringAsFixed(2)}';
    }
    return 'UGX ${discountedPrice.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}';
  }

  String getFormattedOriginalPrice(String currencyCode) {
    if (currencyCode == 'USD') {
      double usdPrice = price / 3800;
      return '\$${usdPrice.toStringAsFixed(2)}';
    }
    return 'UGX ${price.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}';
  }

  String get formattedPrice => getFormattedPrice('UGX');
  String get formattedOriginalPrice => getFormattedOriginalPrice('UGX');

  bool get isOnSale => discountedPrice < price;

  String get discountPercentage {
    if (!isOnSale) return '';
    final savings = ((price - discountedPrice) / price) * 100;
    return '-${savings.round()}%';
  }

  bool get isInStock => !stockStatus;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imgUrl': imgUrl,
      'images': images,
      'price': price,
      'discountedPrice': discountedPrice,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'titleAr': titleAr,
      'descriptionAr': descriptionAr,
      'isOutOfStock': isOutOfStock,
      'colors': colors,
      'sizes': sizes,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ?? 
              (map['imgUrl'] != null ? [map['imgUrl'].toString()] : []),
      price: (map['price'] as num? ?? 0.0).toDouble(),
      discountedPrice: (map['discountedPrice'] as num? ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      rating: (map['rating'] as num? ?? 4.5).toDouble(),
      reviewCount: (map['reviewCount'] as num? ?? 0).toInt(),
      titleAr: map['titleAr'],
      descriptionAr: map['descriptionAr'],
      isOutOfStock: map['isOutOfStock'] ?? false,
      colors: (map['colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      sizes: (map['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
