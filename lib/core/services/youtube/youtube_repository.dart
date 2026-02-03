import 'dart:io';

abstract class YouTubeRepository {
  /// Upload a video to the user's or admin's YouTube channel.
  Future<String> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    bool isPublic = false,
  });

  /// Get video details by ID.
  Future<Map<String, dynamic>?> getVideoDetails(String videoId);

  /// Search for wedding templates (if needed for the gallery).
  Future<List<Map<String, dynamic>>> searchVideos(String query);
}
