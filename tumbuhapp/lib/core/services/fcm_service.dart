import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Top-level background handler — HARUS top-level function (bukan method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tumbuh_notifikasi', // id
    'Notifikasi Tumbuh', // name
    description: 'Notifikasi dari aplikasi Tumbuh',
    importance: Importance.high,
  );

  // ── Inisialisasi ──────────────────────────────

  static Future<void> initialize() async {
    // [1] Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // [2] Buat notification channel (Android)
    if (Platform.isAndroid) {
      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // [3] Init local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // [4] Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // [5] Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // [6] Handle notification tap saat app dari terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] Opened from terminated: ${initialMessage.notification?.title}');
    }

    // [7] Handle notification tap saat app di background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from background: ${message.notification?.title}');
    });
  }

  // ── Get FCM Token ─────────────────────────────

  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
      return null;
    }
  }

  // ── Handle Foreground Message ─────────────────

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    debugPrint('[FCM] Foreground: ${notification.title}');

    // Tampilkan local notification
    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Handle Notification Tap ───────────────────

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Notification tapped: ${response.payload}');
    // Navigasi bisa ditambahkan di sini via global navigator key
  }
}
