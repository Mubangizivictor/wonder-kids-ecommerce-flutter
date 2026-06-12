import 'package:ecom/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailMarketingKey = 'email_marketing';
  static const String _currencyKey = 'currency';

  bool _pushNotifications = true;
  bool _emailMarketing = false;
  String _currency = 'UGX';

  bool get pushNotifications => _pushNotifications;
  bool get emailMarketing => _emailMarketing;
  String get currency => _currency;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _pushNotifications = prefs.getBool(_pushNotificationsKey) ?? true;
    _emailMarketing = prefs.getBool(_emailMarketingKey) ?? false;
    _currency = prefs.getString(_currencyKey) ?? 'UGX';
    
    // Sync notifications on load
    _syncNotificationSubscriptions();
    
    notifyListeners();
  }

  Future<void> togglePushNotifications(bool value) async {
    _pushNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
    _syncNotificationSubscriptions();
  }

  Future<void> toggleEmailMarketing(bool value) async {
    _emailMarketing = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailMarketingKey, value);
    _syncNotificationSubscriptions();
  }

  void _syncNotificationSubscriptions() {
    final ns = NotificationService();
    if (_pushNotifications) {
      ns.subscribeToTopic('all_notifications');
    } else {
      ns.unsubscribeFromTopic('all_notifications');
    }

    if (_emailMarketing) {
      ns.subscribeToTopic('marketing_notifications');
    } else {
      ns.unsubscribeFromTopic('marketing_notifications');
    }
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, value);
  }
}
