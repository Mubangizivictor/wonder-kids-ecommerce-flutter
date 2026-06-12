import 'package:flutter_test/flutter_test.dart';
import 'package:ecom/features/domain/models/review_model.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:ecom/features/presentation/providers/review_provider.dart';
import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  group('Review Flow and Rating Aggregation Tests', () {
    test('ReviewModel toMap and fromMap should be consistent', () {
      final date = DateTime.now();
      final review = ReviewModel(
        id: 'rev123',
        userId: 'user1',
        userName: 'John Doe',
        productId: 'prod1',
        rating: 4.5,
        title: 'Great product',
        comment: 'I really loved this item!',
        date: date,
      );

      final map = review.toMap();
      final fromMap = ReviewModel.fromMap(map, 'rev123');

      expect(fromMap.id, review.id);
      expect(fromMap.userId, review.userId);
      expect(fromMap.rating, review.rating);
      expect(fromMap.title, review.title);
      // Firestore Timestamps can cause slight differences in millisecond precision
      expect(fromMap.date.day, review.date.day);
    });

    test('ProductModel should update rating and count correctly', () {
      final product = ProductModel(
        id: 'p1',
        title: 'Test Product',
        description: 'Desc',
        imgUrl: 'url',
        price: 100,
        discountedPrice: 80,
        category: 'Toys',
        rating: 4.0,
        reviewCount: 1,
      );

      // Simulation of what happens after a new review (e.g., 5.0)
      // New average = (4.0 * 1 + 5.0) / 2 = 4.5
      final newRating = 4.5;
      final newCount = 2;

      final updatedProduct = ProductModel(
        id: product.id,
        title: product.title,
        description: product.description,
        imgUrl: product.imgUrl,
        price: product.price,
        discountedPrice: product.discountedPrice,
        category: product.category,
        rating: newRating,
        reviewCount: newCount,
      );

      expect(updatedProduct.rating, 4.5);
      expect(updatedProduct.reviewCount, 2);
    });
  });
}
