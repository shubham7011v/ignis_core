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

  const Short({
    required this.id,
    required this.title,
    required this.category,
    this.videoUrl,
    this.thumbnailUrl,
    required this.placeholderColor,
    this.isFavorite = false,
  });

  Short copyWith({
    String? id,
    String? title,
    String? category,
    String? videoUrl,
    String? thumbnailUrl,
    int? placeholderColor,
    bool? isFavorite,
  }) {
    return Short(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      placeholderColor: placeholderColor ?? this.placeholderColor,
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
    isFavorite,
  ];
}
