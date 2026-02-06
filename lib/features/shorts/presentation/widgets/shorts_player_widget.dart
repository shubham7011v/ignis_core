import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/short.dart';

class ShortsPlayerWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (controller != null && isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: VideoPlayer(controller!),
          ),
        ),
      );
    }

    // Placeholder / Thumbnail
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Color(short.placeholderColor)),
        if (short.thumbnailUrl != null)
          Image.network(
            short.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Color(short.placeholderColor)),
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
