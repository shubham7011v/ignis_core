import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/app_logger.dart';
import '../../config/api_config.dart';

class UserRepository {
  UserRepository();

  /// Syncs the authenticated Firebase user with the backend database.
  /// This ensures a user record exists in PostgreSQL for admin promotion and order tracking.
  Future<void> syncUser(auth.User firebaseUser) async {
    AppLogger.info('User: Syncing user info', data: {'uid': firebaseUser.uid});

    try {
      final token = await firebaseUser.getIdToken();
      if (token == null) {
        AppLogger.warning('User: Failed to get ID token');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.authVerify),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'User: Sync successful',
          data: json.decode(response.body),
        );
      } else {
        AppLogger.error(
          'User: Sync failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.error('User: Sync exception', exception: e);
      // Don't rethrow, as this shouldn't block the app flow, but it IS critical for backend features.
    }
  }
}
