import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/core/services/notification_service.dart';
import 'package:ecom/features/domain/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  late Box<NotificationModel> _box;
  List<NotificationModel> _notifications = [];
  StreamSubscription? _firestoreSubscription;

  NotificationProvider() {
    _box = Hive.box<NotificationModel>('notifications_box');
    _loadNotifications();
    _listenToPushNotifications();
    _listenToFirestoreNotifications();
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  void _loadNotifications() {
    _notifications = _box.values.toList().reversed.toList();
    notifyListeners();
  }

  void _listenToPushNotifications() {
    NotificationService().messageStream.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        addNotification(
          title: notification.title ?? 'New Notification',
          subtitle: notification.body ?? '',
          type: _determineType(message),
        );
      }
    });
  }

  void _listenToFirestoreNotifications() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel();
      
      // Listen to both user-specific AND global ('all') notifications
      final query = FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', whereIn: [user?.uid ?? 'guest', 'all'])
          .orderBy('timestamp', descending: true);

      _firestoreSubscription = query.snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data != null) {
              final id = change.doc.id;
              // Only add if not already in local Hive storage
              if (!_box.containsKey(id)) {
                final timestamp = data['timestamp'] as Timestamp?;
                final timeText = timestamp != null
                    ? DateFormat('MMM dd, HH:mm').format(timestamp.toDate())
                    : 'Just now';

                _addNotificationFromData(
                  id: id,
                  title: data['title'] ?? 'Notification',
                  subtitle: data['subtitle'] ?? '',
                  typeString: data['type'] ?? 'system',
                  time: timeText,
                );
              }
            }
          }
        }
      }, onError: (e) => debugPrint('Firestore Notification Error: $e'));
    });
  }

  /// Sends a notification to ALL users (Admin Feature)
  Future<void> sendBroadcastNotification({
    required String title,
    required String subtitle,
    required NotificationType type,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': 'all',
        'title': title,
        'subtitle': subtitle,
        'type': type.name,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Error sending broadcast: $e');
      rethrow;
    }
  }

  Future<void> _addNotificationFromData({
    required String id,
    required String title,
    required String subtitle,
    required String typeString,
    required String time,
  }) async {
    final type = _parseType(typeString);
    final icon = _getIconForType(type);

    final newNotification = NotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      time: time,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage,
      isRead: false,
      type: type,
    );

    await _box.put(id, newNotification);
    _loadNotifications();
  }

  NotificationType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return NotificationType.order;
      case 'promotion':
        return NotificationType.promotion;
      case 'security':
        return NotificationType.security;
      default:
        return NotificationType.system;
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return LucideIcons.package;
      case NotificationType.promotion:
        return LucideIcons.tag;
      case NotificationType.security:
        return LucideIcons.shieldCheck;
      case NotificationType.system:
        return LucideIcons.bell;
    }
  }

  NotificationType _determineType(dynamic message) {
    return NotificationType.system;
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> addNotification({
    required String title,
    required String subtitle,
    required NotificationType type,
    IconData? icon,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notificationIcon = icon ?? _getIconForType(type);

    final newNotification = NotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      time: 'Just now',
      iconCodePoint: notificationIcon.codePoint,
      iconFontFamily: notificationIcon.fontFamily,
      iconFontPackage: notificationIcon.fontPackage,
      isRead: false,
      type: type,
    );

    await _box.put(id, newNotification);
    _loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    final notification = _box.get(id);
    if (notification != null) {
      await _box.put(id, notification.copyWith(isRead: true));
      _loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    for (var notification in _box.values) {
      if (!notification.isRead) {
        await _box.put(notification.id, notification.copyWith(isRead: true));
      }
    }
    _loadNotifications();
  }

  Future<void> clearNotifications() async {
    await _box.clear();
    _loadNotifications();
  }

  Future<void> removeNotification(String id) async {
    await _box.delete(id);
    _loadNotifications();
  }
}
