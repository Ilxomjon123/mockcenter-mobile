import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api;

  NotificationService(this._api);

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupToken();
      _listenTokenRefresh();
    }

    // Foreground message handling
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // iOS foreground notification display
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _setupToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _api.post('/app/profile/fcm-token', body: {
        'token': token,
        'device_type': Platform.isIOS ? 'ios' : 'android',
      }, auth: true);
    } catch (e) {
      debugPrint('Failed to send FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Opened from notification: ${message.data}');
  }
}
