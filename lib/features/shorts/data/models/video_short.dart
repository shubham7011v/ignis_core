import 'package:equatable/equatable.dart';

class VideoShort extends Equatable {
  final String title;
  final String category;
  final int color;
  final String? videoUrl; // For future usage
  final String? thumbnailUrl; // For future usage

  const VideoShort({
    required this.title,
    required this.category,
    required this.color,
    this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [title, category, color, videoUrl, thumbnailUrl];
}
