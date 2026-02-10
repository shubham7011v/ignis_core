import 'package:equatable/equatable.dart';

/// Domain entity representing a short-form video template
class Short extends Equatable {
  final String id;
  final String title;
  final String category;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int placeholderColor;
  final bool isFavorite;
  final String? templateId;

  const Short({
    required this.id,
    required this.title,
    required this.category,
    this.videoUrl,
    this.thumbnailUrl,
    required this.placeholderColor,
    this.templateId,
    this.isFavorite = false,
  });

  Short copyWith({
    String? id,
    String? title,
    String? category,
    String? videoUrl,
    String? thumbnailUrl,
    int? placeholderColor,
    String? templateId,
    bool? isFavorite,
  }) {
    return Short(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      templateId: templateId ?? this.templateId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    videoUrl,
    thumbnailUrl,
    placeholderColor,
    templateId,
    isFavorite,
  ];
}
