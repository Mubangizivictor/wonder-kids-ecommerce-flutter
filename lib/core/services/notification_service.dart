import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Stream for incoming messages
  final StreamController<RemoteMessage> _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  // Define the high importance channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // 1. Request permission for iOS/Android 13+
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // 2. Initialize local notifications for foreground display
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      
      const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      // 3. Create the notification channel on Android
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      try {
        // On iOS, we MUST have an APNS token before we can ask for an FCM token.
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          final apnsToken = await _fcm.getAPNSToken();
          if (apnsToken == null) {
            if (kDebugMode) {
              print('APNS token is null. Skipping FCM token retrieval.');
            }
            return;
          }
        }

        // 4. Get FCM Token
        String? token = await _fcm.getToken();
        if (kDebugMode) {
          print("FCM Token: $token");
        }

        if (token != null) {
          await saveTokenToFirestore(token);
        }

        // Listen for token refresh
        _fcm.onTokenRefresh.listen(saveTokenToFirestore);

        // 5. Subscribe to global topic for broadcasts
        await _fcm.subscribeToTopic('all_users');

      } catch (e) {
        if (kDebugMode) {
          print("Caught Notification Error: $e");
        }
      }

      // 5. Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 6. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Add to stream so providers can listen
        _messageStreamController.add(message);
        
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null && !kIsWeb) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: android.smallIcon,
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // 7. Handle notification click when app is in background but opened
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _messageStreamController.add(message);
        if (kDebugMode) {
          print('A new onMessageOpenedApp event was published!');
        }
        // Handle navigation or logic here
      });

      // 8. Check if app was opened from a terminated state via notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _messageStreamController.add(initialMessage);
         if (kDebugMode) {
          print('App opened from terminated state via notification');
        }
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) return;
      }
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) return;
      }
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      if (kDebugMode) print('Error unsubscribing from topic: $e');
    }
  }

  Future<void> saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `Firebase.initializeApp()` before using other Firebase services.
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
  }
}
