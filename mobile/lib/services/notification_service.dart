import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiService _api = Get.find<ApiService>();

  Future<NotificationService> init() async {
    // ... initialization code
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get auth controller to listen for login
    final auth = Get.find<AuthController>();
    ever(auth.user, (user) async {
      if (user != null) {
        String? token = await _fcm.getToken();
        if (token != null) {
          print("FCM Token: $token");
          await _registerToken(token);
        }
      }
    });

    if (auth.isLoggedIn) {
      String? token = await _fcm.getToken();
      if (token != null) {
        _registerToken(token);
      }
    }

    // Refresh token listener
    _fcm.onTokenRefresh.listen((newToken) async {
      if (auth.isLoggedIn) {
        await _registerToken(newToken);
      }
    });

    // Handle incoming messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    return this;
  }

  Future<void> _registerToken(String token) async {
    try {
      await _api.post('/fcm-token', data: {'token': token});
      print("FCM Token registered with backend");
    } catch (e) {
      print("Failed to register FCM Token: $e");
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final data = Map<String, dynamic>.from(
        Uri.splitQueryString(response.payload!),
      );

      if (data['type'] == 'new_message') {
        final conversationId = int.parse(data['conversation_id']);
        // Need to find the conversation object or fetch it
        // For now, we can redirect to home or try to find it in HomeController
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          final conversation = homeController.conversations.firstWhereOrNull(
            (c) => c.id == conversationId,
          );
          if (conversation != null) {
            Get.toNamed('/chat', arguments: conversation);
          } else {
            Get.offAllNamed('/home');
          }
        }
      } else if (data['type'] == 'friend_request' || data['type'] == 'friend_request_accepted') {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print("Error handling notification tap: $e");
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Create a payload string from data
      final payload = Uri(queryParameters: Map<String, String>.from(message.data)).query;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    }
  }
}

// Background handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
