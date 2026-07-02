import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../network/dio_client.dart';
import '../constant/api_constants.dart';

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

  /// Global navigator key untuk navigasi dari notifikasi
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
      debugPrint(
          '[FCM] Opened from terminated: ${initialMessage.notification?.title}');
      _handleNotificationNavigation(initialMessage.data);
    }

    // [7] Handle notification tap saat app di background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
          '[FCM] Opened from background: ${message.notification?.title}');
      _handleNotificationNavigation(message.data);
    });

    // [8] Listen token refresh — kirim token baru ke backend
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: ${newToken.substring(0, 20)}...');
      _sendTokenToServer(newToken);
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

  // ── Kirim Token ke Server ─────────────────────

  static Future<void> _sendTokenToServer(String token) async {
    try {
      await DioClient.instance.put(
        ApiConstants.updateFcmToken,
        data: {'fcm_token': token},
      );
      debugPrint('[FCM] Token berhasil dikirim ke server');
    } catch (e) {
      debugPrint('[FCM] Gagal kirim token ke server: $e');
    }
  }

  // ── Handle Foreground Message ─────────────────

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    debugPrint('[FCM] Foreground: ${notification.title}');

    // Encode data ke payload agar bisa dipakai saat notifikasi di-tap
    final payload = _encodePayload(message.data);

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
      payload: payload,
    );
  }

  // ── Handle Notification Tap ───────────────────

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Notification tapped: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) return;

    final data = _decodePayload(response.payload!);
    _handleNotificationNavigation(data);
  }

  // ── Navigasi Berdasarkan Data Notifikasi ──────

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Tunggu sebentar agar navigator sudah siap
    Future.delayed(const Duration(milliseconds: 500), () {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('[FCM] Navigator belum siap, navigasi dibatalkan');
        return;
      }

      final tipe = data['tipe'] as String?;

      switch (tipe) {
        case 'jadwal':
          navigator.pushNamed('/jadwal');
          break;
        case 'rujukan':
          final anakId = data['anak_id'] as String?;
          if (anakId != null) {
            navigator.pushNamed('/anak/$anakId/rujukan');
          } else {
            navigator.pushNamed('/notifikasi');
          }
          break;
        default:
          // Default: buka halaman notifikasi
          navigator.pushNamed('/notifikasi');
          break;
      }
    });
  }

  // ── Payload Helpers ───────────────────────────

  /// Encode Map<String, dynamic> ke string "key1=val1&key2=val2"
  static String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// Decode string payload kembali ke Map
  static Map<String, dynamic> _decodePayload(String payload) {
    final map = <String, dynamic>{};
    for (final pair in payload.split('&')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}
