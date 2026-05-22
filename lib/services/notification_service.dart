import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ── Handler background top-level ─────────────────────────────────────────────
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('📲 Tap background : ${response.payload}');
}

// ── Instance globale du plugin ────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _fcm = FirebaseMessaging.instance;

  static const _channel = AndroidNotificationChannel(
    'snap_voyance_channel',
    'Snap Voyance',
    description: 'Notifications de prédictions et horoscope',
    importance: Importance.high,
  );

  Future<void> init() async {
    await _requestPermissions();
    await _setupLocalNotifications();

    // Notifications foreground FCM
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _listenMessages();

    final token = await _fcm.getToken();
    debugPrint('🔑 FCM Token : $token');
  }

  Future<void> _requestPermissions() async {
    // FCM (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ local notifications
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // iOS local notifications
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _setupLocalNotifications() async {
    // Canal Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const initAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const initIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // v21 : paramètre nommé `settings`
    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: initAndroid,
        iOS: initIOS,
      ),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('📲 Notification tapée : ${details.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void _listenMessages() {
    // Foreground → afficher via flutter_local_notifications
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Foreground : ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // App ouverte depuis notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Opened via notif : ${message.notification?.title}');
    });

    // App lancée depuis notification (état terminated)
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('🚀 Launched via notif : ${message.notification?.title}');
      }
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    // v21 : paramètres nommés pour show()
    flutterLocalNotificationsPlugin.show(
      id: notif.hashCode,
      title: notif.title,
      body: notif.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
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

  Future<String?> getToken() => _fcm.getToken();

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('✅ Abonné : $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint('❌ Désabonné : $topic');
  }
}