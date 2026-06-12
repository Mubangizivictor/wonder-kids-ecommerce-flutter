import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String productId;
  final double rating;
  final String title;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      productId: map['productId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      title: map['title'] ?? '',
      comment: map['comment'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
