import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../../core/utils/app_logger.dart';

class ShortsVideoService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Extracts the direct stream URL for a given YouTube video ID.
  /// Returns the highest quality muxed stream (video + audio) URL.
  Future<String?> getStreamUrl(String videoId) async {
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      var streamInfo = manifest.muxed.withHighestBitrate();
      return streamInfo.url.toString();
    } catch (e) {
      AppLogger.error(
        'Error extracting stream for video $videoId',
        exception: e,
      );
      return null;
    }
  }

  /// Disposes the YoutubeExplode client.
  void dispose() {
    _yt.close();
  }
}
