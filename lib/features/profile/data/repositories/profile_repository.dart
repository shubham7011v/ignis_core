import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_profile.dart';
import '../../../auth/domain/models/user_stats.dart';
import '../../../../core/config/app_config.dart';

class ProfileRepository {
  ProfileRepository();

  /// Get a user's profile by their ID
  Future<UserProfile> getProfile(String userId) async {
    // For MVP, we'll use the current user's data if it's their own profile
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = currentUser?.uid == userId;

    if (isOwnProfile && currentUser != null) {
      final stats = const UserStats(
        userId: '',
        name: '',
        invitationsCreated: 0,
        guestsCount: 0,
        rsvpsReceived: 0,
      );

      return UserProfile(
        userId: currentUser.uid,
        name: currentUser.displayName ?? 'Unknown',
        photoUrl: currentUser.photoURL,
        bio: null, // Not implemented yet
        stats: stats,
        isOnline: true,
        isFriend: false,
        joinedDate: currentUser.metadata.creationTime ?? DateTime.now(),
      );
    }

    // For other users, fetch from backend API
    try {
      final url = Uri.parse('${AppConfig.instance.apiBaseUrl}/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if friend
        final isFriend = await this.isFriend(userId);

        return UserProfile(
          userId: userId,
          name: data['name'] ?? 'Unknown',
          photoUrl: data['photoUrl'],
          bio: data['bio'],
          stats: UserStats.fromJson(data['stats'] ?? {}),
          isOnline: data['isOnline'] ?? false,
          isFriend: isFriend,
          joinedDate: DateTime.parse(
            data['createdAt'] ?? DateTime.now().toIso8601String(),
          ),
        );
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback for demo
      return UserProfile(
        userId: userId,
        name: 'User',
        photoUrl: null,
        bio: 'Wedding planning journey started.',
        stats: const UserStats(
          userId: '',
          name: '',
          invitationsCreated: 0,
          guestsCount: 0,
          rsvpsReceived: 0,
        ),
        isOnline: false,
        isFriend: false,
        joinedDate: DateTime.now(),
      );
    }
  }

  /// Check if a user is your friend
  Future<bool> isFriend(String userId) async {
    // TODO: Implement friend check via REST API
    return false;
  }

  /// Add a user as a friend
  Future<void> addFriend(String userId) async {
    // TODO: Implement add friend via REST API
  }

  /// Remove a friend
  Future<void> removeFriend(String userId) async {
    // TODO: Implement remove friend via REST API
  }
}
