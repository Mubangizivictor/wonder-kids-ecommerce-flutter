import 'package:ecom/core/theme/v_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  bool _isDark;

  ThemeProvider({bool initialIsDark = false}) : _isDark = initialIsDark;

  bool get isDark => _isDark;
  ThemeData get themeData => _isDark ? VAppTheme.dark : VAppTheme.light;

  // Toggle and save the preference
  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);
  }

  // Static method to get initial theme before app starts
  static Future<bool> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
