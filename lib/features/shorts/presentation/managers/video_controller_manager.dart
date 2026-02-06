import 'package:video_player/video_player.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/services/shorts_video_service.dart';

class VideoControllerManager {
  final ShortsVideoService _videoService;
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initializedIndices = {};

  VideoControllerManager(this._videoService);

  /// Returns an initialized controller for the given index if available.
  VideoPlayerController? getController(int index) => _controllers[index];

  /// Checks if the controller at the given index is initialized.
  bool isInitialized(int index) => _initializedIndices.contains(index);

  /// Preloads video at [index] with [videoId].
  /// Ideally specific to the current page index to manage a sliding window.
  Future<void> preload(int index, String videoUrl) async {
    if (_controllers.containsKey(index)) return;

    // Determine if it's a YouTube ID or a direct URL (simple check)
    String? streamUrl = videoUrl;
    if (!videoUrl.startsWith('http')) {
      // Assume it's a YouTube ID
      streamUrl = await _videoService.getStreamUrl(videoUrl);
    }

    if (streamUrl == null) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    _controllers[index] = controller;

    try {
      await controller.initialize();
      _initializedIndices.add(index);
      // Ensure it doesn't auto-play immediately, just buffer
      // controller.setLooping(true); // Optional: loop by default for shorts
    } catch (e) {
      AppLogger.error(
        'Error initializing controller at index $index',
        exception: e,
      );
      _controllers.remove(index);
    }
  }

  /// Plays the video at [index] and pauses neighbors.
  void play(int index) {
    _controllers[index]?.play();
    _controllers[index]?.setLooping(true);
  }

  /// Pauses the video at [index].
  void pause(int index) {
    _controllers[index]?.pause();
  }

  /// Disposes controllers outside the active window [currentIndex - 1, currentIndex + 1].
  /// This implements the "sliding window" resource management.
  void disposeMetrics(int currentIndex) {
    final keysToRemove = <int>[];
    _controllers.forEach((key, controller) {
      if (key < currentIndex - 1 || key > currentIndex + 2) {
        controller.dispose();
        keysToRemove.add(key);
        _initializedIndices.remove(key);
      }
    });

    for (var key in keysToRemove) {
      _controllers.remove(key);
    }
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initializedIndices.clear();
    _videoService.dispose();
  }
}
