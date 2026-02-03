import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ignis_core/core/utils/app_logger.dart';
import 'package:ignis_core/core/di/service_locator.dart';
import 'package:ignis_core/core/notifications/bloc/app_notification_event.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `await Firebase.initializeApp()` here.
  AppLogger.info("Handling a background message: ${message.messageId}");
}

class NotificationService {
  // Lazy initialization to avoid NotInitializedError before Firebase.initializeApp()
  FirebaseMessaging? _fcmInstance;
  FirebaseMessaging get _fcm {
    _fcmInstance ??= FirebaseMessaging.instance;
    return _fcmInstance!;
  }

  static bool _backgroundHandlerRegistered = false;

  Future<void> initialize() async {
    // 1. Request Permission (critical for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Critical alerts if needed
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      AppLogger.info('User granted provisional permission');
    } else {
      AppLogger.info('User declined or has not accepted permission');
      return;
    }

    // 2. Set Foreground Notification Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Got a message whilst in the foreground!');
      AppLogger.info('Message data: ${message.data}');

      if (message.notification != null) {
        AppLogger.info(
          'Message also contained a notification: ${message.notification}',
        );

        // Show in-app notification via Bloc
        sl.notificationBloc.add(
          ShowInfoNotification(
            "${message.notification!.title}: ${message.notification!.body}",
          ),
        );
      }
    });

    // 3. Set Background/Terminated Handler
    if (!_backgroundHandlerRegistered) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _backgroundHandlerRegistered = true;
      AppLogger.info('FCM Background Handler registered');
    }

    // 4. Handle notification tap when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('A new onMessageOpenedApp event was published!');
      _handleMessageInteraction(message);
    });

    // 5. Handle notification tap when app was terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageInteraction(initialMessage);
    }

    // 6. Get Token
    final token = await _fcm.getToken();
    AppLogger.info("FCM Token: $token");
    // Token can be sent to backend via REST API if needed
  }

  Future<void> _handleMessageInteraction(RemoteMessage message) async {
    AppLogger.info('📬 Notification tapped: ${message.data}');

    // Give Firebase Auth time to reinitialize if app was terminated
    // This is critical because auth state may not be ready immediately
    await Future.delayed(const Duration(milliseconds: 500));

    // Auth check only
    final user = sl.authRepository.currentUser;
    if (user == null) {
      AppLogger.info(
        '❌ No user found, cannot process notification interaction',
      );
      return;
    }

    // Handle specific notification types
    if (message.data.containsKey('type')) {
      final type = message.data['type'];
      AppLogger.info('Notification type: $type');

      // Handle wedding-related notification types here
      // For example, 'invitation_ready', 'rsvp_update', etc.

      if (type == 'invitation_ready') {
        final videoId = message.data['videoId'];
        AppLogger.info("Invitation video ready: $videoId");
        // Navigate to Creations Gallery or specific video
      }
    }
  }
}
