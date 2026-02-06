import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/short.dart';

class ShortsPlayerWidget extends StatefulWidget {
  final Short short;
  final VideoPlayerController? controller;
  final bool isInitialized;

  const ShortsPlayerWidget({
    super.key,
    required this.short,
    this.controller,
    this.isInitialized = false,
  });

  @override
  State<ShortsPlayerWidget> createState() => _ShortsPlayerWidgetState();
}

class _ShortsPlayerWidgetState extends State<ShortsPlayerWidget> {
  bool _isPlaying = true;
  bool _showControls = false;

  void _togglePlay() {
    if (widget.controller == null || !widget.isInitialized) return;

    setState(() {
      if (widget.controller!.value.isPlaying) {
        widget.controller!.pause();
        _isPlaying = false;
        _showControls = true; // Always show controls when paused
      } else {
        widget.controller!.play();
        _isPlaying = true;
        _showControls = true;
        // Hide controls after delay
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
    if (widget.controller != null && widget.isInitialized) {
      return GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // Video Layer
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: widget.controller!.value.size.width,
                  height: widget.controller!.value.size.height,
                  child: VideoPlayer(widget.controller!),
                ),
              ),
            ),

            // Play/Pause Overlay
            if (_showControls || !_isPlaying)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 72,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Placeholder / Thumbnail
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Color(widget.short.placeholderColor)),
        if (widget.short.thumbnailUrl != null)
          Image.network(
            widget.short.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Color(widget.short.placeholderColor)),
          ),
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}
