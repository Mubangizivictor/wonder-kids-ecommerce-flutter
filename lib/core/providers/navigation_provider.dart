import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void navigateToShop() {
    setIndex(1);
  }

  void navigateToHome() {
    setIndex(0);
  }

  void navigateToCart() {
    setIndex(3);
  }
}
