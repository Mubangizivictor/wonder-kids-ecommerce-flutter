import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/features/domain/models/category_model.dart';
import 'package:ecom/core/constants/category_list.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _categorySubscription;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryProvider() {
    startCategoryListener();
  }

  void startCategoryListener() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _categorySubscription?.cancel();
    _categorySubscription = _firestore
        .collection('categories')
        .snapshots()
        .listen(
      (snapshot) {
        _categories = snapshot.docs.map((doc) {
          final data = doc.data();
          return CategoryModel(
            id: data['id'] ?? 0,
            titleKey: data['title'] ?? '',
            icon: _mapStringToIcon(data['iconName'] ?? 'layoutGrid'),
          );
        }).toList();
        
        _categories.sort((a, b) => a.id.compareTo(b.id));
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Category Stream Error: $error');
        _errorMessage = error.toString();
        _categories = CategoryList.catList; // Fallback
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    startCategoryListener();
  }

  Future<void> seedCategories() async {
    for (var cat in CategoryList.catList) {
      if (cat.titleKey == "All") continue; 
      await _firestore.collection('categories').doc(cat.titleKey).set({
        'id': cat.id,
        'title': cat.titleKey,
        'iconName': _mapIconToString(cat.icon),
      });
    }
    await fetchCategories();
  }

  Future<void> addCategory(String titleKey, IconData icon) async {
    try {
      final nextId = _categories.isEmpty ? 0 : _categories.last.id + 1;
      await _firestore.collection('categories').doc(titleKey).set({
        'id': nextId,
        'title': titleKey,
        'iconName': _mapIconToString(icon),
      });
      await fetchCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String oldTitleKey, String newTitleKey, IconData icon) async {
    try {
      final doc = await _firestore.collection('categories').doc(oldTitleKey).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (oldTitleKey != newTitleKey) {
          await _firestore.collection('categories').doc(oldTitleKey).delete();
        }
        await _firestore.collection('categories').doc(newTitleKey).set({
          'id': data['id'],
          'title': newTitleKey,
          'iconName': _mapIconToString(icon),
        });
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String titleKey) async {
    try {
      await _firestore.collection('categories').doc(titleKey).delete();
      await fetchCategories();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  IconData _mapStringToIcon(String name) {
    switch (name) {
      case 'rocket': return LucideIcons.rocket;
      case 'shirt': return LucideIcons.shirt;
      case 'baby': return LucideIcons.baby;
      case 'bookOpen': return LucideIcons.bookOpen;
      case 'footprints': return LucideIcons.footprints;
      case 'layoutGrid':
      default: return LucideIcons.layoutGrid;
    }
  }

  String _mapIconToString(IconData icon) {
    if (icon == LucideIcons.rocket) return 'rocket';
    if (icon == LucideIcons.shirt) return 'shirt';
    if (icon == LucideIcons.baby) return 'baby';
    if (icon == LucideIcons.bookOpen) return 'bookOpen';
    if (icon == LucideIcons.footprints) return 'footprints';
    return 'layoutGrid';
  }

  Future<void> clearAllCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing categories: $e');
    }
  }
}
