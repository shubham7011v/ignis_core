import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../utils/app_logger.dart';

class UserRepository {
  UserRepository();

  /// No-op for now.
  /// User basic info is managed by FirebaseAuth.
  Future<void> syncUser(auth.User firebaseUser) async {
    AppLogger.info('User: Syncing user info', data: {'uid': firebaseUser.uid});
    // Migration: We no longer sync to Firestore.
    // The Go backend handles stats sync via AUTH message.
  }
}
