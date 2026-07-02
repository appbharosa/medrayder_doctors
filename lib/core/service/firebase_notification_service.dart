import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../main.dart';


class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
  static Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();

    // Get the token and store it (optional)
    _getAndStoreToken();

    // Listen for messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for messages when the app is in the background/terminated
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    // Handle initial message (when app is opened from terminated state)
    final RemoteMessage? initialMessage =
    await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// Request notification permissions (iOS & Android)
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  /// Retrieve and store FCM token
  static Future<void> _getAndStoreToken() async {
    String? token = await _messaging.getToken();
    if (token != null) {
      debugPrint('📱 FCM Token: $token');
      // Optionally send token to your backend
      // await UserManager.updateFcmToken(token);
    }
  }

  /// Handle token refresh
  static Future<void> _handleTokenRefresh(String newToken) async {
    debugPrint('🔄 FCM Token refreshed: $newToken');
    // Optionally send new token to your backend
    // await UserManager.updateFcmToken(newToken);
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Foreground message received: ${message.notification?.title}');
    // Show a local notification or update UI state
    _showLocalNotification(message);
  }

  /// Handle background/terminated messages
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('📨 Background message received: ${message.notification?.title}');
    // You can process the message here (e.g., update cache, etc.)
    // For Flutter, background handlers must be top-level or static.
  }

  /// Handle any incoming message (foreground, background, or terminated)
  static void _handleMessage(RemoteMessage message) {
    // Extract data from message
    final data = message.data;
    final notification = message.notification;

    // Example: navigate to a specific screen based on payload
    String? screen = data['screen']; // e.g., "appointment", "prescription"
    String? bookingId = data['booking_id'];

    // Navigate using the global navigator key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (screen != null && bookingId != null) {
      //  _navigateToScreen(screen, bookingId);
      }
    });

    // Show a local notification (optional)
    _showLocalNotification(message);
  }

  /// Show a local notification (for foreground messages)
  static void _showLocalNotification(RemoteMessage message) {
    // You can integrate flutter_local_notifications here if needed
    // For now, we just print it.
    debugPrint('🔔 Notification: ${message.notification?.title}');
  }


}