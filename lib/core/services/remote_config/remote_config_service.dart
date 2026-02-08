import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_logger.dart';

class RemoteConfigService {
  final FirebaseFirestore _firestore;

  RemoteConfigService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _configCollection = 'config';
  static const String _appDocId = 'app';

  /// Listens to real-time configuration changes from Firestore.
  /// This allows the app to respond instantly to maintenance mode or feature flags.
  Stream<Map<String, dynamic>> watchConfig() {
    return _firestore
        .collection(_configCollection)
        .doc(_appDocId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return snapshot.data() as Map<String, dynamic>;
          }
          return <String, dynamic>{};
        });
  }

  /// Fetches the current configuration once.
  Future<Map<String, dynamic>> fetchConfig() async {
    try {
      final doc = await _firestore
          .collection(_configCollection)
          .doc(_appDocId)
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error(
        'RemoteConfigService: Failed to fetch config',
        exception: e,
      );
    }
    return <String, dynamic>{};
  }
}
