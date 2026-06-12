import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale;

  LocaleProvider({String? initialLanguageCode})
      : _locale = Locale(initialLanguageCode ?? 'en');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  static Future<String?> getLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }
}
