import 'package:equatable/equatable.dart';

class Template extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String category;
  final String duration;
  final bool isPremium;
  final String? youtubeId; // YouTube video ID for downloading

  const Template({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    required this.duration,
    this.isPremium = false,
    this.youtubeId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnailUrl,
    videoUrl,
    category,
    duration,
    isPremium,
    youtubeId,
  ];

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      category: json['category'] as String,
      duration: json['duration'] as String,
      isPremium: (json['isPremium'] as bool?) ?? false,
      youtubeId: json['youtubeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'category': category,
      'duration': duration,
      'isPremium': isPremium,
      'youtubeId': youtubeId,
    };
  }
}
