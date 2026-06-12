import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('date', descending: true)
          .get();

      _reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      // Ensure the review userId matches the current user for security
      // (This should also be enforced by Firestore rules)
      final docRef = await _firestore.collection('reviews').add(review.toMap());
      final newReview = ReviewModel(
        id: docRef.id,
        userId: review.userId,
        userName: review.userName,
        productId: review.productId,
        rating: review.rating,
        title: review.title,
        comment: review.comment,
        date: review.date,
      );
      _reviews.insert(0, newReview);
      
      // Update product rating and count in Firestore
      await _updateProductRating(review.productId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      final averageRating = totalRating / snapshot.docs.length;

      await _firestore.collection('products').doc(productId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'reviewCount': snapshot.docs.length,
      });
    } catch (e) {
      debugPrint('Error updating product rating: $e');
    }
  }
}
