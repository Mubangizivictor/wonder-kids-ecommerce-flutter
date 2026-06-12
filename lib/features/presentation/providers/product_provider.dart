import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isDialogLoading = false;
  String? _errorMessage;
  StreamSubscription? _productsSubscription;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isDialogLoading => _isDialogLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    startProductListener();
  }

  void setDialogLoading(bool value) {
    _isDialogLoading = value;
    notifyListeners();
  }

  void startProductListener() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _productsSubscription?.cancel();
    _productsSubscription = _firestore
        .collection('products')
        .snapshots()
        .listen(
      (snapshot) {
        _products = snapshot.docs.map((doc) {
          return ProductModel.fromMap({...doc.data(), 'id': doc.id});
        }).toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Products Stream Error: $error');
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    startProductListener();
  }

  Future<void> seedProducts() async {
    final List<Map<String, dynamic>> seedData = [
      // CLOTHING (6 Products)
      {
        'title': "Kids' Organic Cotton Polo",
        'description': "Premium 100% breathable cotton polo shirt. Fade-resistant fabric perfect for Kampala weather. Features a classic two-button placket.",
        'price': 35000.0,
        'discountedPrice': 28000.0,
        'category': "Clothing",
        'colors': ["Navy", "White", "Red"],
        'sizes': ["2-3Y", "4-5Y", "6-7Y"],
        'imgUrl': "https://images.unsplash.com/photo-1519235106638-30cc49bc6305?q=80&w=600",
        'rating': 4.8,
        'reviewCount': 12,
      },
      {
        'title': "Girls' Floral Party Dress",
        'description': "Beautiful A-line dress with vibrant floral patterns and cotton lining. Includes a matching hair ribbon. Ideal for birthday parties.",
        'price': 65000.0,
        'discountedPrice': 55000.0,
        'category': "Clothing",
        'colors': ["Pink", "Yellow"],
        'sizes': ["3Y", "4Y", "5Y"],
        'imgUrl': "https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?q=80&w=600",
        'rating': 4.9,
        'reviewCount': 25,
      },
      {
        'title': "Toddler Denim Overalls",
        'description': "Durable washed denim dungarees with adjustable straps. Reinforced stitching at knees for active play.",
        'price': 55000.0,
        'discountedPrice': 45000.0,
        'category': "Clothing",
        'colors': ["Blue Denim", "Light Wash"],
        'sizes': ["18M", "2Y", "3Y"],
        'imgUrl': "https://images.unsplash.com/photo-1519457431-757395461b14?q=80&w=600",
        'rating': 4.7,
        'reviewCount': 18,
      },
      {
        'title': "Character Pajama Set",
        'description': "Soft jersey cotton sleepwear. Breathable and snug-fit for safety. Features fun glow-in-the-dark prints.",
        'price': 40000.0,
        'discountedPrice': 32000.0,
        'category': "Clothing",
        'colors': ["Space", "Dino"],
        'sizes': ["2Y", "4Y", "6Y"],
        'imgUrl': "https://images.unsplash.com/photo-1555009393-f20bdb245c4d?q=80&w=600",
        'rating': 4.6,
        'reviewCount': 30,
      },
      {
        'title': "Boys' Chino Shorts Pack",
        'description': "Pack of 2 versatile chino shorts. Adjustable waistband for the perfect fit. Durable fabric for school or play.",
        'price': 45000.0,
        'discountedPrice': 38000.0,
        'category': "Clothing",
        'colors': ["Khaki/Navy", "Grey/Black"],
        'sizes': ["4Y", "6Y", "8Y"],
        'imgUrl': "https://images.unsplash.com/photo-1519235106638-30cc49bc6305?q=80&w=601",
        'rating': 4.5,
        'reviewCount': 10,
      },
      {
        'title': "Infant Knitted Sweater",
        'description': "Hand-finished soft wool blend sweater. Perfect for chilly Kampala mornings. Gentle on sensitive skin.",
        'price': 42000.0,
        'discountedPrice': 35000.0,
        'category': "Clothing",
        'colors': ["Cream", "Grey"],
        'sizes': ["6M", "12M", "18M"],
        'imgUrl': "https://images.unsplash.com/photo-1519235106638-30cc49bc6305?q=80&w=602",
        'rating': 4.7,
        'reviewCount': 8,
      },

      // TOYS & LEARNING (6 Products)
      {
        'title': "Interactive Learning Table",
        'description': "Introduces numbers, letters, colors, and music. Features spinning gears and a light-up piano. Encourages motor skills.",
        'price': 180000.0,
        'discountedPrice': 155000.0,
        'category': "Toys & Learning",
        'colors': ["Multicolor"],
        'sizes': ["Standard"],
        'imgUrl': "https://images.unsplash.com/photo-1515488764276-beab7607c1e6?q=80&w=600",
        'rating': 4.9,
        'reviewCount': 45,
      },
      {
        'title': "RC Stunt Racing Car",
        'description': "360-degree spinning stunt car with LED lights. Shock-resistant tires for all-terrain indoor/outdoor action.",
        'price': 120000.0,
        'discountedPrice': 95000.0,
        'category': "Toys & Learning",
        'colors': ["Red", "Blue"],
        'sizes': ["1:18 Scale"],
        'imgUrl': "https://images.unsplash.com/photo-1594787318286-3d835c1d207f?q=80&w=600",
        'rating': 4.5,
        'reviewCount': 22,
      },
      {
        'title': "Wooden Building Blocks (100pc)",
        'description': "Eco-friendly natural wood blocks. Promotes spatial awareness and creativity. Includes a sorting storage tub.",
        'price': 85000.0,
        'discountedPrice': 72000.0,
        'category': "Toys & Learning",
        'colors': ["Natural"],
        'sizes': ["Large Set"],
        'imgUrl': "https://images.unsplash.com/photo-1587654780291-39c9404d746b?q=80&w=600",
        'rating': 5.0,
        'reviewCount': 50,
      },
      {
        'title': "Doctor Roleplay Kit",
        'description': "Complete medical kit with stethoscope, thermometer, and more. Encourages imaginative play and social skills.",
        'price': 55000.0,
        'discountedPrice': 48000.0,
        'category': "Toys & Learning",
        'colors': ["Cyan", "Pink"],
        'sizes': ["One Size"],
        'imgUrl': "https://images.unsplash.com/photo-1515488764276-beab7607c1e6?q=80&w=601",
        'rating': 4.6,
        'reviewCount': 15,
      },
      {
        'title': "Magnetic Tiles Set",
        'description': "3D magnetic building tiles. Strong magnets and BPA-free plastic. Perfect for STEM learning and construction.",
        'price': 140000.0,
        'discountedPrice': 125000.0,
        'category': "Toys & Learning",
        'colors': ["Mixed"],
        'sizes': ["60 Pieces"],
        'imgUrl': "https://images.unsplash.com/photo-1515488764276-beab7607c1e6?q=80&w=602",
        'rating': 4.8,
        'reviewCount': 30,
      },
      {
        'title': "Musical Xylophone Toy",
        'description': "Colorful metal keys produce pleasant tones. Safe, non-toxic wood construction for early musical exploration.",
        'price': 45000.0,
        'discountedPrice': 38000.0,
        'category': "Toys & Learning",
        'colors': ["Rainbow"],
        'sizes': ["Small"],
        'imgUrl': "https://images.unsplash.com/photo-1515488764276-beab7607c1e6?q=80&w=603",
        'rating': 4.7,
        'reviewCount': 40,
      },

      // BABY GEAR (6 Products)
      {
        'title': "3-in-1 Comfort Stroller",
        'description': "Reversible seat with one-hand fold mechanism. All-terrain shock wheels and UV-protected canopy.",
        'price': 550000.0,
        'discountedPrice': 485000.0,
        'category': "Baby Gear",
        'colors': ["Grey", "Black"],
        'sizes': ["Standard"],
        'imgUrl': "https://images.unsplash.com/photo-1591954840042-76dca34271b4?q=80&w=600",
        'rating': 4.7,
        'reviewCount': 10,
      },
      {
        'title': "Smart Baby Monitor",
        'description': "HD video with night vision and two-way talk. Temperature sensor and lullaby player included.",
        'price': 280000.0,
        'discountedPrice': 245000.0,
        'category': "Baby Gear",
        'colors': ["White"],
        'sizes': ["1080p"],
        'imgUrl': "https://images.unsplash.com/photo-1522771935876-24917180eeaf?q=80&w=600",
        'rating': 4.5,
        'reviewCount': 12,
      },
      {
        'title': "Insulated Diaper Backpack",
        'description': "14 pockets with 3 insulated bottle holders and waterproof wet-pocket. Includes changing mat.",
        'price': 145000.0,
        'discountedPrice': 120000.0,
        'category': "Baby Gear",
        'colors': ["Maroon", "Charcoal"],
        'sizes': ["20L"],
        'imgUrl': "https://images.unsplash.com/photo-1584006682522-dc17d6c0d9ac?q=80&w=600",
        'rating': 4.8,
        'reviewCount': 42,
      },
      {
        'title': "Electric Breast Pump",
        'description': "Quiet and efficient with 9 suction levels. Rechargeable via USB. BPA-free medical grade material.",
        'price': 250000.0,
        'discountedPrice': 210000.0,
        'category': "Baby Gear",
        'colors': ["Pink"],
        'sizes': ["Dual-Mode"],
        'imgUrl': "https://images.unsplash.com/photo-1555009393-f20bdb245c4d?q=80&w=601",
        'rating': 4.6,
        'reviewCount': 18,
      },
      {
        'title': "Convertible High Chair",
        'description': "Grows with your baby from 6 months to 6 years. Easy-clean tray and 5-point safety harness.",
        'price': 320000.0,
        'discountedPrice': 285000.0,
        'category': "Baby Gear",
        'colors': ["White/Oak", "Blue"],
        'sizes': ["Adjustable"],
        'imgUrl': "https://images.unsplash.com/photo-1591954840042-76dca34271b4?q=80&w=601",
        'rating': 4.9,
        'reviewCount': 15,
      },
      {
        'title': "Baby Carrier Ergonomic",
        'description': "Multi-position carrier with lumbar support. Breathable mesh fabric for maximum airflow.",
        'price': 120000.0,
        'discountedPrice': 98000.0,
        'category': "Baby Gear",
        'colors': ["Navy", "Grey"],
        'sizes': ["Standard"],
        'imgUrl': "https://images.unsplash.com/photo-1584006682522-dc17d6c0d9ac?q=80&w=601",
        'rating': 4.7,
        'reviewCount': 20,
      },

      // SCHOOL & STATIONERY (6 Products)
      {
        'title': "Orthopedic School Backpack",
        'description': "Lightweight with lumbar support and padded straps. Multiple compartments and reflective safety strips.",
        'price': 85000.0,
        'discountedPrice': 70000.0,
        'category': "School & Stationery",
        'colors': ["Blue", "Pink", "Black"],
        'sizes': ["Large"],
        'imgUrl': "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=600",
        'rating': 4.7,
        'reviewCount': 55,
      },
      {
        'title': "Deluxe Art Kit (150pc)",
        'description': "Complete set with watercolors, oil pastels, and markers in a portable wooden case.",
        'price': 65000.0,
        'discountedPrice': 55000.0,
        'category': "School & Stationery",
        'colors': ["Oak Case"],
        'sizes': ["150pc"],
        'imgUrl': "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=600",
        'rating': 5.0,
        'reviewCount': 88,
      },
      {
        'title': "Kids' GPS Tracker Watch",
        'description': "Two-way voice calls, SOS button, and real-time tracking. Water-resistant with educational games.",
        'price': 160000.0,
        'discountedPrice': 135000.0,
        'category': "School & Stationery",
        'colors': ["Blue", "Rose"],
        'sizes': ["Standard"],
        'imgUrl': "https://images.unsplash.com/photo-1544117518-3baf3525d848?q=80&w=600",
        'rating': 4.4,
        'reviewCount': 20,
      },
      {
        'title': "Bento Lunch Box Set",
        'description': "Leak-proof compartments with matching water bottle. Microwave and dishwasher safe.",
        'price': 45000.0,
        'discountedPrice': 38000.0,
        'category': "School & Stationery",
        'colors': ["Green", "Purple"],
        'sizes': ["800ml"],
        'imgUrl': "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=601",
        'rating': 4.6,
        'reviewCount': 35,
      },
      {
        'title': "Washable Marker Set (24)",
        'description': "Ultra-clean washable markers. Easily washes from skin and most children's clothing.",
        'price': 25000.0,
        'discountedPrice': 20000.0,
        'category': "School & Stationery",
        'colors': ["24 Colors"],
        'sizes': ["Standard"],
        'imgUrl': "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=601",
        'rating': 4.8,
        'reviewCount': 42,
      },
      {
        'title': "Geometric Math Set",
        'description': "Essential geometry tools in a durable tin case. Includes compass, protractor, and rulers.",
        'price': 15000.0,
        'discountedPrice': 12000.0,
        'category': "School & Stationery",
        'colors': ["Silver"],
        'sizes': ["9pc"],
        'imgUrl': "https://images.unsplash.com/photo-1544117518-3baf3525d848?q=80&w=601",
        'rating': 4.5,
        'reviewCount': 100,
      },

      // FOOTWEAR (6 Products)
      {
        'title': "LED Light-Up Sneakers",
        'description': "Rechargeable LED soles with 7 color modes. Breathable mesh and easy velcro straps.",
        'price': 95000.0,
        'discountedPrice': 78000.0,
        'category': "Footwear",
        'colors': ["Silver", "Black"],
        'sizes': ["26", "28", "30"],
        'imgUrl': "https://images.unsplash.com/photo-1514989940723-e8e51635b782?q=80&w=600",
        'rating': 4.8,
        'reviewCount': 62,
      },
      {
        'title': "Genuine Leather School Shoes",
        'description': "Scuff-resistant premium leather. Padded collar and non-slip rubber sole for all-day comfort.",
        'price': 110000.0,
        'discountedPrice': 89000.0,
        'category': "Footwear",
        'colors': ["Black", "Brown"],
        'sizes': ["30", "32", "34", "36"],
        'imgUrl': "https://images.unsplash.com/photo-1515488764276-beab7607c1e6?q=80&w=600",
        'rating': 4.9,
        'reviewCount': 40,
      },
      {
        'title': "Glitter Party Flats",
        'description': "Sparkling ballet flats with soft lining and elastic strap. Perfect for special occasions.",
        'price': 55000.0,
        'discountedPrice': 45000.0,
        'category': "Footwear",
        'colors': ["Gold", "Silver"],
        'sizes': ["24", "26", "28"],
        'imgUrl': "https://images.unsplash.com/photo-1520633640453-294903332306?q=80&w=600",
        'rating': 4.7,
        'reviewCount': 15,
      },
      {
        'title': "All-Terrain Adventure Sandals",
        'description': "Quick-dry straps with protective toe bumper. Ideal for beach and outdoor active play.",
        'price': 65000.0,
        'discountedPrice': 52000.0,
        'category': "Footwear",
        'colors': ["Blue", "Green"],
        'sizes': ["25", "27", "29"],
        'imgUrl': "https://images.unsplash.com/photo-1515488764276-beab7607c1e6?q=80&w=601",
        'rating': 4.6,
        'reviewCount': 28,
      },
      {
        'title': "Rain Boots (Yellow Duck)",
        'description': "100% waterproof natural rubber. Features easy-pull handles and slip-resistant soles.",
        'price': 45000.0,
        'discountedPrice': 38000.0,
        'category': "Footwear",
        'colors': ["Yellow", "Pink"],
        'sizes': ["22", "24", "26"],
        'imgUrl': "https://images.unsplash.com/photo-1514989940723-e8e51635b782?q=80&w=601",
        'rating': 4.9,
        'reviewCount': 22,
      },
      {
        'title': "Infant Soft-Sole Booties",
        'description': "Handmade leather booties with elastic ankle. Supports natural foot development for crawlers.",
        'price': 35000.0,
        'discountedPrice': 28000.0,
        'category': "Footwear",
        'colors': ["Tan", "White"],
        'sizes': ["3M", "6M", "12M"],
        'imgUrl': "https://images.unsplash.com/photo-1520633640453-294903332306?q=80&w=601",
        'rating': 4.8,
        'reviewCount': 12,
      },
    ];

    try {
      final batch = _firestore.batch();
      for (var data in seedData) {
        final docRef = _firestore.collection('products').doc();
        batch.set(docRef, data);
      }
      await batch.commit();
      debugPrint('Successfully seeded ${seedData.length} products to Firestore.');
    } catch (e) {
      debugPrint('Error seeding products: $e');
      rethrow;
    }
  }

  // Admin: Add new product
  Future<void> addProduct(ProductModel product) async {
    try {
      // Generate a new document reference to get a unique ID
      final docRef = _firestore.collection('products').doc();
      final productWithId = ProductModel(
        id: docRef.id,
        title: product.title,
        description: product.description,
        imgUrl: product.imgUrl,
        price: product.price,
        discountedPrice: product.discountedPrice,
        category: product.category,
        rating: product.rating,
        reviewCount: product.reviewCount,
        titleAr: product.titleAr,
        descriptionAr: product.descriptionAr,
        images: product.images,
        isOutOfStock: product.isOutOfStock,
        colors: product.colors,
        sizes: product.sizes,
      );
      
      await docRef.set(productWithId.toMap());
      
      // Update local list immediately for better responsiveness
      // The listener will eventually sync with the server version
      if (!_products.any((p) => p.id == productWithId.id)) {
        _products.add(productWithId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  // Admin: Update existing product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      
      // Update local list
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // Admin: Delete product and its images
  Future<void> deleteProductWithImages(String productId, List<String> images) async {
    try {
      // 1. Delete from Firestore
      await _firestore.collection('products').doc(productId).delete();
      
      // 2. Delete all images from Storage
      for (String url in images) {
        if (url.contains('firebasestorage.googleapis.com')) {
          try {
            await FirebaseStorage.instance.refFromURL(url).delete();
          } catch (e) {
            debugPrint('Error deleting product image from storage: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Legacy delete method
  Future<void> deleteProduct(String productId, {String? imgUrl}) async {
    await deleteProductWithImages(productId, imgUrl != null ? [imgUrl] : []);
  }

  List<ProductModel> getFilteredProducts({
    required String categoryTitle,
    required String searchQuery,
    required String priceRange,
    int sortIndex = 0,
    String currency = 'UGX',
  }) {
    List<ProductModel> filtered = _products.where((product) {
      // Normalize category for backward compatibility (Baby Essentials -> Baby Gear)
      String effectiveCategory = product.category;
      if (effectiveCategory == "Baby Essentials") {
        effectiveCategory = "Baby Gear";
      }

      final matchesCategory = categoryTitle == "All" || effectiveCategory == categoryTitle;
      final matchesSearch = product.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
                           product.description.toLowerCase().contains(searchQuery.toLowerCase());
      
      bool matchesPrice = true;
      if (priceRange != 'All') {
        final price = product.discountedPrice;
        if (priceRange == 'Under 50k') {
          matchesPrice = price < 50000;
        } else if (priceRange == '50k - 150k') {
          matchesPrice = price >= 50000 && price <= 150000;
        } else if (priceRange == '150k - 300k') {
          matchesPrice = price > 150000 && price <= 300000;
        } else if (priceRange == 'Above 300k') {
          matchesPrice = price > 300000;
        }
      }

      return matchesCategory && matchesSearch && matchesPrice;
    }).toList();

    // Apply Sorting
    switch (sortIndex) {
      case 1: // Price: Low to High
        filtered.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case 2: // Price: High to Low
        filtered.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case 4: // Best Selling
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return filtered;
  }
}
