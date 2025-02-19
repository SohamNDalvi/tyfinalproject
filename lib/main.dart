import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';

// Local Notification Plugin Instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _requestPermissions();
  await saveFcmToken();

  // Initialize Local Notifications
  await initLocalNotifications();

  // Handle background & foreground notifications
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📢 Foreground Notification Received: ${message.notification?.title}");
    showLocalNotification(message);
  });

  runApp(const MyApp());
}

// 🔔 Background Notification Handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Background Notification: ${message.notification?.title}");
}

// 🚀 Request Notification Permissions
Future<void> _requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.getNotificationSettings();

  if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    NotificationSettings newSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔹 User granted permission: ${newSettings.authorizationStatus}');
  } else {
    print('🔹 Notification permission: ${settings.authorizationStatus}');
  }
}

// 💾 Save FCM Token
Future<void> saveFcmToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? existingToken = prefs.getString('fcm_token');

  if (existingToken == null) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();

    if (fcmToken != null) {
      await prefs.setString('fcm_token', fcmToken);
      print("✅ FCM Token Stored: $fcmToken");
    } else {
      print("❌ Failed to get FCM Token");
    }
  } else {
    print("✅ FCM Token already exists: $existingToken");
  }
}

// 📲 Initialize Local Notifications
Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settings);
}

// 🎯 Show Local Notification
void showLocalNotification(RemoteMessage message) {
  String? title = message.notification?.title;
  String? body = message.notification?.body;

  // Only show notification if title or body is not empty
  if ((title != null && title.isNotEmpty) || (body != null && body.isNotEmpty)) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      0,
      title ?? "No Title",
      body ?? "No Body",
      details,
    );
  } else {
    print("🚫 Notification ignored: No title or body");
  }
}


// 🌟 Flutter App
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Firebase Initialization Failed")),
            );
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
