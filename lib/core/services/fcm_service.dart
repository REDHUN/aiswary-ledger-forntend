import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';
import 'storage_service.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('FCM Background message received: ${message.messageId} | ${message.notification?.title}');
  } catch (e) {
    debugPrint('Error in FCM background handler: $e');
  }
}

class FcmService {
  final StorageService _storageService;
  final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notification alerts.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  FcmService(this._storageService, this._apiClient);

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Check if Firebase Messaging is supported and enabled on current platform
  static bool get isSupported {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return true;
      case TargetPlatform.iOS:
      default:
        return false;
    }
  }

  /// Initialize FCM listeners, local notification channels, and token sync
  Future<void> initialize() async {
    if (!isSupported) {
      debugPrint('FCM is not supported on this platform: $defaultTargetPlatform');
      return;
    }

    try {
      // 1. Request notification permissions (Android 13+ & iOS)
      await requestPermission();

      // 2. Set foreground presentation options for Firebase
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Setup local notification channel for Android foreground display
      await _setupLocalNotifications();

      // 4. Foreground message listener -> Display via FlutterLocalNotificationsPlugin
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'FCM Foreground message received: ${message.notification?.title} - ${message.notification?.body}',
        );
        _showForegroundNotification(message);
      });

      // 5. Handle notification click when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
          'FCM Message opened from background: ${message.notification?.title}',
        );
      });

      // 6. Handle token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token refreshed: $newToken');
        await _storageService.saveFcmToken(newToken);
        if (_storageService.hasSession()) {
          await sendTokenToBackend(newToken);
        }
      });

      // 7. Sync token with backend if user is already logged in
      if (_storageService.hasSession()) {
        debugPrint('Active user session detected. Syncing FCM token with backend...');
        await getToken();
      }
    } catch (e) {
      debugPrint('Error initializing FCM service: $e');
    }
  }

  /// Setup local notifications channel and settings
  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification clicked: ${response.payload}');
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }
  }

  /// Display a heads-up banner when notification arrives in the foreground
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'Aiswarya Ledger',
      body: notification.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  /// Request notification permissions (Android 13+ & iOS)
  Future<NotificationSettings?> requestPermission() async {
    if (!isSupported) return null;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('FCM Permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('Error requesting FCM permission: $e');
      return null;
    }
  }

  /// Get device FCM registration token and sync with backend
  Future<String?> getToken() async {
    if (!isSupported) {
      debugPrint('FCM getToken skipped: platform not supported');
      return null;
    }

    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token fetched: $token');
      if (token != null && token.isNotEmpty) {
        await _storageService.saveFcmToken(token);
        if (_storageService.hasSession()) {
          await sendTokenToBackend(token);
        }
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Send FCM token to backend (POST /api/v1/fcm-tokens)
  Future<void> sendTokenToBackend(String token) async {
    try {
      await _apiClient.request(
        path: ApiEndpoints.fcmTokens,
        method: RequestType.post,
        body: {'fcmToken': token},
      );
      debugPrint('FCM Token registered with backend successfully');
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
    }
  }

  /// Delete FCM registration token from backend (DELETE /api/v1/fcm-tokens?fcmToken=...)
  Future<void> deleteTokenFromBackend(String token) async {
    try {
      await _apiClient.request(
        path: ApiEndpoints.deleteFcmToken(token),
        method: RequestType.delete,
      );
      debugPrint('FCM Token deleted from backend successfully');
    } catch (e) {
      debugPrint('Error deleting FCM token from backend: $e');
    }
  }

  /// Delete FCM registration token locally and on backend upon logout
  Future<void> deleteToken() async {
    if (!isSupported) return;

    final existingToken = _storageService.getFcmToken();
    if (existingToken != null && existingToken.isNotEmpty) {
      await deleteTokenFromBackend(existingToken);
    }

    try {
      await _messaging.deleteToken();
      debugPrint('FCM Token deleted from Firebase');
    } catch (e) {
      debugPrint('Error deleting FCM token from Firebase: $e');
    }

    await _storageService.clearFcmToken();
  }
}
