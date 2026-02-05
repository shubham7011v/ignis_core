import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';
import 'session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user to delete');
    }

    final uid = user.uid;

    try {
      AppLogger.info('Starting account deletion', data: {'uid': uid});

      // 1. Delete user profile data
      await _firestore.collection('users').doc(uid).delete();
      AppLogger.info('User profile deleted');

      // 2. Delete all user orders
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in ordersSnapshot.docs) {
        await doc.reference.delete();
      }
      AppLogger.info(
        'User orders deleted',
        data: {'count': ordersSnapshot.size},
      );

      // 3. Delete user favorites (if stored in Firestore)
      try {
        final favoritesRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('favorites');
        final favoritesSnapshot = await favoritesRef.get();

        for (var doc in favoritesSnapshot.docs) {
          await doc.reference.delete();
        }
        AppLogger.info(
          'User favorites deleted',
          data: {'count': favoritesSnapshot.size},
        );
      } catch (e) {
        AppLogger.warning('Error deleting favorites', exception: e);
        // Continue even if favorites deletion fails
      }

      // 4. Delete any user-specific settings or preferences
      try {
        await _firestore.collection('user_settings').doc(uid).delete();
        AppLogger.info('User settings deleted');
      } catch (e) {
        AppLogger.warning('Error deleting settings', exception: e);
        // Continue even if settings deletion fails
      }

      // 5. Delete Firebase Auth account (this will trigger re-auth if needed)
      await user.delete();
      AppLogger.info('Firebase Auth account deleted successfully');

      AppLogger.info(
        'Account deletion completed successfully',
        data: {'uid': uid},
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppLogger.error('Account deletion requires recent login', exception: e);
        throw Exception(
          'For security, please sign out and sign in again before deleting your account.',
        );
      }
      AppLogger.error(
        'Firebase Auth error during account deletion',
        exception: e,
      );
      rethrow;
    } catch (e) {
      AppLogger.error('Account deletion failed', exception: e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    // Nothing to dispose
  }
}
