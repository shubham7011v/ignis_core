import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/short.dart';

class ShortsPlayerWidget extends StatefulWidget {
  final Short short;
  final bool shouldPlay;

  const ShortsPlayerWidget({
    super.key,
    required this.short,
    this.shouldPlay = false,
  });

  @override
  State<ShortsPlayerWidget> createState() => _ShortsPlayerWidgetState();
}

class _ShortsPlayerWidgetState extends State<ShortsPlayerWidget> {
  bool _isPlaying = true;
  bool _showControls = false;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
  }

  @override
  void didUpdateWidget(ShortsPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay != oldWidget.shouldPlay) {
      if (widget.shouldPlay) {
        _play();
      } else {
        _pause();
      }
    }
  }

  void _initializeYoutubePlayer() {
    String? videoId = widget.short.youtubeId;

    if (videoId != null && videoId.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.shouldPlay,
          mute: false,
          loop: true,
          hideControls: true,
          forceHD: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _play() {
    if (_youtubeController != null) {
      _youtubeController!.play();
      if (mounted) setState(() => _isPlaying = true);
    }
  }

  void _pause() {
    if (_youtubeController != null) {
      _youtubeController!.pause();
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _togglePlay() {
    if (_youtubeController == null) return;

    setState(() {
      if (_youtubeController!.value.isPlaying) {
        _youtubeController!.pause();
        _isPlaying = false;
        _showControls = true;
      } else {
        _youtubeController!.play();
        _isPlaying = true;
        _showControls = true;
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. YouTube Player
    if (_youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
        builder: (context, player) {
          return GestureDetector(
            onTap: _togglePlay,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                player,
                if (_showControls || !_isPlaying)
                  Container(
                    color: Colors.black26,
                    child: Center(
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    // Placeholder / Thumbnail (Fallback)
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Color(widget.short.placeholderColor)),
        if (widget.short.thumbnailUrl != null)
          Image.network(
            widget.short.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(color: Color(widget.short.placeholderColor)),
          ),
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('Invalid YouTube ID', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
