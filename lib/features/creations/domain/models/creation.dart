import 'package:equatable/equatable.dart';

class Creation extends Equatable {
  final String id;
  final String title;
  final String templateId;
  final String thumbnailUrl;
  final String videoUrl;
  final DateTime createdAt;

  const Creation({
    required this.id,
    required this.title,
    required this.templateId,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    templateId,
    thumbnailUrl,
    videoUrl,
    createdAt,
  ];

  factory Creation.fromJson(Map<String, dynamic> json) {
    return Creation(
      id: json['id'] as String,
      title: json['title'] as String,
      templateId: json['templateId'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'templateId': templateId,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
