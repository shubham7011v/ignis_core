import 'package:equatable/equatable.dart';
import '../../../../core/enums/template_enums.dart';

class Template extends Equatable {
  final String id;
  final String title;
  final String description;
  final TemplateCategory category;
  final String duration;
  final double cost;
  final String? youtubeId; // YouTube video ID for downloading

  const Template({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    this.cost = 0.0,
    this.youtubeId,
  });

  String get thumbnailUrl => youtubeId != null
      ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
      : '';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    duration,
    cost,
    youtubeId,
  ];

  factory Template.fromJson(Map<String, dynamic> json) {
    // Server returns priceCents (e.g. 49900 for 499.00)
    // Or sometimes just priceCents for whole units?
    // Let's assume priceCents is the source of truth.
    final priceCents = (json['priceCents'] as num?)?.toDouble() ?? 0.0;
    return Template(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TemplateCategory.fromString(
        json['category'] as String? ?? 'Modern',
      ),
      duration: json['duration'] as String,
      cost: priceCents / 100.0,
      youtubeId: json['youtubeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toServerString(),
      'duration': duration,
      'priceCents': (cost * 100).toInt(),
      'youtubeId': youtubeId,
    };
  }
}
