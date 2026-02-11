import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/app_logger.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';

class UserRepository {
  UserRepository();

  /// Syncs the authenticated Firebase user with the backend database.
  /// This ensures a user record exists in PostgreSQL for admin promotion and order tracking.
  /// Returns [true] if the user is confirmed as an admin.
  Future<bool> syncUser(auth.User firebaseUser) async {
    AppLogger.info('User: Syncing user info', data: {'uid': firebaseUser.uid});

    try {
      final token = await firebaseUser.getIdToken();
      if (token == null) {
        AppLogger.warning('User: Failed to get ID token');
        return false;
      }

      // Get App Check Token
      String? appCheckToken;
      try {
        final tokenResult = await FirebaseAppCheck.instance.getToken(false);
        appCheckToken = tokenResult;
      } catch (e) {
        AppLogger.warning('User: Failed to get App Check token: $e');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      if (appCheckToken != null) {
        headers['X-Firebase-AppCheck'] = appCheckToken;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.authVerify),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        AppLogger.info('User: Sync successful', data: data);

        // Update Admin Status in AppConfig
        if (data['user'] != null && data['user']['isAdmin'] == true) {
          AppConfig.instance.setAdminStatus(true, firebaseUser.uid);
          AppLogger.info('🚀 [AUTH] User promoted to ADMIN session');
          return true;
        }
      } else {
        AppLogger.error(
          'User: Sync failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.error('User: Sync exception', exception: e);
    }
    return false;
  }
}
