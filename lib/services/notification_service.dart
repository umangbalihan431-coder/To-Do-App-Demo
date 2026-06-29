import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    final box = await Hive.openBox('myBox');
    final count = box.get("NOTIFICATION_COUNT", defaultValue: 0);
    await box.put("NOTIFICATION_COUNT", count + 1);
  }

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(
      settings: initializationSettings,
    );

    const channel = AndroidNotificationChannel(
      'todo_channel',
      'Todo Notifications',
      description: 'Notifications for todo app',
      importance: Importance.high,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final box = Hive.box('myBox');
      final count = box.get("NOTIFICATION_COUNT", defaultValue: 0);
      await box.put("NOTIFICATION_COUNT", count + 1);

      final notification = message.notification;

      if (notification != null) {
        await localNotifications.show(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'todo_channel',
              'Todo Notifications',
              channelDescription: 'Notifications for todo app',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }
}