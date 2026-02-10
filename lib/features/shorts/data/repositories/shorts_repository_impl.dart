import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/short.dart';
import '../../domain/repositories/shorts_repository.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

class ShortsRepositoryImpl implements ShortsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ShortsRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _favoritesCollection => _firestore
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('favorites');

  @override
  Future<List<Short>> getShorts() async {
    try {
      final user = _auth.currentUser;
      final headers = <String, String>{};

      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http.get(
        Uri.parse(ApiConfig.shorts),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['shorts'] ?? [];
        return data.map((item) => _mapToShort(item)).toList();
      } else {
        AppLogger.error(
          'ShortsRepository: Failed to fetch shorts (${response.statusCode})',
        );
      }
    } catch (e) {
      AppLogger.error('ShortsRepository: Fetch exception', exception: e);
    }
    return [];
  }

  @override
  Future<void> toggleFavorite(String shortId, bool isFavorite) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Sync to Firestore (Free Tier - Real-time & Offline)
      if (isFavorite) {
        await _favoritesCollection.doc(shortId).set({
          'templateId': shortId,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _favoritesCollection.doc(shortId).delete();
      }

      // 2. Notify Backend (Sync PostgreSQL)
      final token = await user.getIdToken();
      final url = ApiConfig.shortsToggleFavorite(shortId);

      if (isFavorite) {
        await http.post(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        await http.delete(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      AppLogger.error(
        'ShortsRepository: Toggle favorite exception',
        exception: e,
      );
    }
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final snapshot = await _favoritesCollection.get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      AppLogger.error(
        'ShortsRepository: Get favorite IDs exception',
        exception: e,
      );
      return {};
    }
  }

  Short _mapToShort(Map<String, dynamic> item) {
    return Short(
      id: item['id'] ?? '',
      title: item['title'] ?? '',
      category: item['category'] ?? '',
      videoUrl: item['videoUrl'],
      thumbnailUrl: item['thumbnailUrl'],
      placeholderColor: _parseColor(item['placeholderColor']),
    );
  }

  int _parseColor(String? colorStr) {
    if (colorStr == null) return 0xFF000000;
    try {
      if (colorStr.startsWith('#')) {
        return int.parse(colorStr.replaceFirst('#', '0xFF'));
      }
      return int.parse(colorStr);
    } catch (_) {
      return 0xFF000000;
    }
  }
}
