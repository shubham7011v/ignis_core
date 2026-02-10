import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/short.dart';
import '../../domain/repositories/shorts_repository.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

class ShortsRepositoryImpl implements ShortsRepository {
  final FirebaseAuth _auth;

  ShortsRepositoryImpl({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

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
        return data.map((item) => Short.fromJson(item)).toList();
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
      final token = await user.getIdToken();
      final url = ApiConfig.shortsToggleFavorite(shortId);

      final response = isFavorite
          ? await http.post(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            )
          : await http.delete(
              Uri.parse(url),
              headers: {'Authorization': 'Bearer $token'},
            );

      if (response.statusCode != 200) {
        AppLogger.error(
          'ShortsRepository: Toggle favorite failed (${response.statusCode})',
        );
      }
    } catch (e) {
      AppLogger.error(
        'ShortsRepository: Toggle favorite exception',
        exception: e,
      );
      rethrow;
    }
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse(ApiConfig.shortsFavorites),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['shorts'] ?? [];
        return data.map((item) => item['id'] as String).toSet();
      }
    } catch (e) {
      AppLogger.error(
        'ShortsRepository: Get favorite IDs exception',
        exception: e,
      );
    }
    return {};
  }
}
