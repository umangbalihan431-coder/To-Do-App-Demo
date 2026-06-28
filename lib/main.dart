import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Utils/login_page.dart';
import 'home_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final box = await Hive.openBox('myBox');
  final currentCount = box.get("NOTIFICATION_COUNT", defaultValue: 0);
  await box.put("NOTIFICATION_COUNT", currentCount + 1);
}

Future<void> setupLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'todo_channel',
    'Todo Notifications',
    description: 'Notifications for todo app',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void setupForegroundNotificationListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final box = Hive.box('myBox');
    final currentCount = box.get("NOTIFICATION_COUNT", defaultValue: 0);
    await box.put("NOTIFICATION_COUNT", currentCount + 1);

    final notification = message.notification;

    if (notification != null) {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title,
        notification.body,
        const NotificationDetails(
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Hive.initFlutter();
  await Hive.openBox('myBox');

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  await setupLocalNotifications();
  await FirebaseMessaging.instance.requestPermission();

  setupForegroundNotificationListener();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM TOKEN: $fcmToken");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('myBox');
    final token = box.get('TOKEN');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.yellow,
      ),
      home: token == null ? const LoginPage() : HomePage(),
    );
  }
}