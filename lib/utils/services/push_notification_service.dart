import 'dart:convert';
import 'package:doctors/utils/services/pending_call.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Request permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Doctor App: Firebase notifications permission denied');
        return;
      }

      // Initialize local notifications
      await _initLocalNotifications();

      // Get FCM token (with timeout protection)
      String? token;
      try {
        token = await _firebaseMessaging.getToken();
        debugPrint('Doctor App FCM Token: $token');
        // Optionally send token to your backend
        // await _sendTokenToBackend(token);
      } catch (e) {
        debugPrint('Doctor App: Could not get FCM token (simulator?): $e');
      }

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // App opened from background/terminated state
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // App launched from terminated state by notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleCallData(initialMessage.data);
      }
    } catch (e) {
      debugPrint('Doctor App: FirebaseNotificationService init failed: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channel (required for Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'doctor_notifications',
      'Doctor App Notifications',
      description: 'Notifications for appointments and video calls',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  static void _onNotificationResponse(NotificationResponse details) {
    debugPrint('Doctor App: Notification tapped: ${details.payload}');
    if (details.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(details.payload!);
        _handleCallData(data);
      } catch (e) {
        debugPrint('Doctor App: Error parsing notification payload: $e');
      }
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Doctor App: Foreground message: ${message.data}');
    await _showLocalNotification(message);

    // If it's a video call, handle immediately (auto-navigate)
    if (message.data['call_type'] == 'video') {
      _handleCallData(message.data);
    }
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Doctor App: Opened from background: ${message.data}');
    _handleCallData(message.data);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'doctor_notifications',
        'Doctor App Notifications',
        channelDescription: 'Appointment & video call alerts',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      String payloadJson = jsonEncode(message.data);

      await _localNotifications.show(
        id: notificationId,
        title: message.notification?.title ?? 'MedRayder Doctor',
        body: message.notification?.body ?? 'You have a new notification',
        notificationDetails: notificationDetails,
        payload: payloadJson,
      );
    } catch (e) {
      debugPrint('Doctor App: Failed to show local notification: $e');
    }
  }

  static void _handleCallData(Map<String, dynamic>? data) {
    if (data == null) return;

    // For video calls, store pending data and navigate using global navigatorKey
    if (data['call_type'] == 'video') {
      pendingCallData = data; // from pending_call.dart
      final context = navigatorKey.currentContext;
      if (context != null) {
        _navigateToVideoCall(context, data);
        pendingCallData = null;
      }
    }

    // Handle other notification types (e.g., appointment reminders)
    if (data['type'] == 'appointment_reminder') {
      // Optionally navigate to appointment details
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Navigator.pushNamed(context, '/appointments');
      }
    }
  }

  static void _navigateToVideoCall(BuildContext context, Map<String, dynamic> data) {
    // Adjust parameters according to your Doctor's VideoCallScreen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => VideoCallScreen(
    //       token: data['token'] ?? '',
    //       patientName: data['name'] ?? 'Patient',
    //       patientId: data['patient_id']?.toString() ?? '',
    //       bookingId: data['booking_id']?.toString() ?? '',
    //       roomId: data['room_id']?.toString() ?? '',
    //       consultType: data['consult_type'] ?? 'online',
    //     ),
    //   ),
    // );
  }

  // Helper: Subscribe to a topic (e.g., doctor's ID for targeted messages)
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Optional: Send token to your backend after login
  static Future<void> updateTokenOnServer() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      // Call your API to store token for this doctor
      debugPrint('Doctor App: Sending token to backend: $token');
      // Example: await ApiService.updateFcmToken(token);
    }
  }
}