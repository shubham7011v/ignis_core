import 'package:equatable/equatable.dart';
import '../../../templates/domain/models/template.dart';

/// Domain entity representing a short-form video template
class Short extends Equatable {
  final String id;
  final String title;
  final String category;
  final String? thumbnailUrl;
  final int placeholderColor;
  final bool isFavorite;
  final String? templateId;
  final String? description;
  final String? duration;
  final double cost;
  final String? youtubeId;

  const Short({
    required this.id,
    required this.title,
    required this.category,
    this.thumbnailUrl,
    required this.placeholderColor,
    this.templateId,
    this.isFavorite = false,
    this.description,
    this.duration,
    this.cost = 0.0,
    this.youtubeId,
  });

  Short copyWith({
    String? id,
    String? title,
    String? category,
    String? thumbnailUrl,
    int? placeholderColor,
    String? templateId,
    bool? isFavorite,
    String? description,
    String? duration,
    double? cost,
    String? youtubeId,
  }) {
    return Short(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      templateId: templateId ?? this.templateId,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      cost: cost ?? this.cost,
      youtubeId: youtubeId ?? this.youtubeId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    thumbnailUrl,
    placeholderColor,
    templateId,
    isFavorite,
    description,
    duration,
    cost,
    youtubeId,
  ];

  factory Short.fromJson(Map<String, dynamic> json) {
    return Short(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      thumbnailUrl: (json['thumbnailUrl'] as String?)?.isNotEmpty == true
          ? json['thumbnailUrl'] as String
          : (json['youtubeId'] != null
                ? 'https://img.youtube.com/vi/${json['youtubeId']}/maxresdefault.jpg'
                : null),
      placeholderColor: _parseColor(json['placeholderColor'] as String?),
      templateId: json['id'] as String, // ID is the template ID
      isFavorite: json['isFavorited'] as bool? ?? false,
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      cost: (json['priceCents'] as num?)?.toDouble() ?? 0.0 / 100.0,
      youtubeId: json['youtubeId'] as String?,
    );
  }

  /// Maps this Short back to a Template for ordering
  Template toTemplate() {
    return Template(
      id: id,
      title: title,
      description: description ?? '',
      thumbnailUrl: thumbnailUrl ?? '',
      category: category,
      duration: duration ?? '0:30',
      cost: cost,
      youtubeId: youtubeId,
    );
  }

  static int _parseColor(String? colorStr) {
    if (colorStr == null) return 0xFF000000;
    try {
      if (colorStr.startsWith('#')) {
        return int.parse(colorStr.replaceFirst('#', '0xFF'));
      }
      return int.parse(colorStr);
    } catch (_) {
      return 0xFF000000;
    }
  }
}
