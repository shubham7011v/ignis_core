import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'youtube_repository.dart';
import '../../utils/app_logger.dart';

class YouTubeServiceImpl implements YouTubeRepository {
  final GoogleSignIn _googleSignIn;

  YouTubeServiceImpl({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: [
              YouTubeApi.youtubeUploadScope,
              YouTubeApi.youtubeReadonlyScope,
            ],
          );

  Future<YouTubeApi?> _getYouTubeApi() async {
    final GoogleSignInAccount? account =
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

    if (account == null) {
      AppLogger.error('YouTube Sign-In failed: No account selected.');
      return null;
    }

    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      AppLogger.error(
        'YouTube Auth failed: Could not create authenticated client.',
      );
      return null;
    }

    return YouTubeApi(httpClient);
  }

  @override
  Future<String> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    bool isPublic = false,
  }) async {
    try {
      final youtube = await _getYouTubeApi();
      if (youtube == null) throw Exception('YouTube API not initialized');

      final video = Video();
      video.snippet = VideoSnippet()
        ..title = title
        ..description = description
        ..categoryId = '22'; // People & Blogs

      video.status = VideoStatus()
        ..privacyStatus = isPublic ? 'public' : 'unlisted';

      final media = Media(videoFile.openRead(), videoFile.lengthSync());

      final uploadedVideo = await youtube.videos.insert(video, [
        'snippet',
        'status',
      ], uploadMedia: media);

      AppLogger.info('YouTube upload successful: ${uploadedVideo.id}');
      return uploadedVideo.id!;
    } catch (e) {
      AppLogger.error('YouTube upload failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    try {
      final youtube = await _getYouTubeApi();
      if (youtube == null) return null;

      final response = await youtube.videos.list(
        ['snippet', 'contentDetails', 'statistics'],
        id: [videoId],
      );

      if (response.items == null || response.items!.isEmpty) {
        return null;
      }

      final item = response.items!.first;
      return {
        'id': item.id,
        'title': item.snippet?.title,
        'description': item.snippet?.description,
        'thumbnail': item.snippet?.thumbnails?.high?.url,
        'duration': item.contentDetails?.duration,
        'viewCount': item.statistics?.viewCount,
      };
    } catch (e) {
      AppLogger.error('Flash YouTube get details failed: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    try {
      final youtube = await _getYouTubeApi();
      if (youtube == null) return [];

      final response = await youtube.search.list(
        ['snippet'],
        q: query,
        maxResults: 10,
        type: ['video'],
      );

      return response.items
              ?.map(
                (item) => {
                  'id': item.id?.videoId,
                  'title': item.snippet?.title,
                  'thumbnail': item.snippet?.thumbnails?.high?.url,
                },
              )
              .toList() ??
          [];
    } catch (e) {
      AppLogger.error('YouTube search failed: $e');
      return [];
    }
  }
}
