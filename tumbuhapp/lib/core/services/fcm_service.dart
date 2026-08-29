import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/notification_navigation.dart';
import '../network/dio_client.dart';
import '../constant/api_constants.dart';
import '../utils/storage_utils.dart';

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

  /// Callback dipanggil setiap kali notifikasi FCM baru masuk (foreground).
  /// Assign dari dashboard untuk refresh badge count.
  static VoidCallback? onNewMessage;

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
      unawaited(_handleNotificationNavigation(initialMessage.data));
    }

    // [7] Handle notification tap saat app di background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
          '[FCM] Opened from background: ${message.notification?.title}');
      unawaited(_handleNotificationNavigation(message.data));
    });

    // [8] Listen token refresh — kirim token baru ke backend
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed');
      unawaited(_sendTokenToServer(newToken));
    });
  }

  // ── Get FCM Token ─────────────────────────────

  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token tersedia: ${token != null}');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
      return null;
    }
  }

  // ── Kirim Token ke Server ─────────────────────

  static Future<void> _sendTokenToServer(String token) async {
    if (!await StorageUtils.isLoggedIn()) return;
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

    // Refresh badge count di dashboard
    onNewMessage?.call();
  }

  // ── Handle Notification Tap ───────────────────

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Notification tapped: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) return;

    final data = _decodePayload(response.payload!);
    unawaited(_handleNotificationNavigation(data));
  }

  // ── Navigasi Berdasarkan Data Notifikasi ──────

  static Future<void> _handleNotificationNavigation(
    Map<String, dynamic> data,
  ) async {
    final path = NotificationNavigation.pathFromData(data);
    for (var attempt = 0; attempt < 10; attempt++) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        GoRouter.of(context).push(path);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    debugPrint('[FCM] Router belum siap, navigasi dibatalkan');
  }

  // ── Payload Helpers ───────────────────────────

  static String _encodePayload(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> _decodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }
}
