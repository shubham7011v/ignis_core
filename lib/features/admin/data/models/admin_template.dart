import '../../../../features/templates/domain/models/template.dart';

class AdminTemplate {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String youtubeId;
  final String category;
  final double price;
  final int viewCount;
  final bool isActive;
  final String? overlayConfig; // JSON String

  const AdminTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.youtubeId,
    required this.category,
    required this.price,
    required this.viewCount,
    required this.isActive,
    this.overlayConfig,
  });

  factory AdminTemplate.fromJson(Map<String, dynamic> json) {
    return AdminTemplate(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: (json['thumbnailUrl'] as String?)?.isNotEmpty == true
          ? json['thumbnailUrl'] as String
          : (json['youtubeId'] != null
                ? 'https://img.youtube.com/vi/${json['youtubeId']}/maxresdefault.jpg'
                : ''),
      youtubeId: json['youtubeId'] ?? '',
      category: json['category'] ?? '',
      price: ((json['priceCents'] as num?)?.toDouble() ?? 0) / 100.0,
      viewCount: json['viewCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      overlayConfig: json['overlayConfig']
          ?.toString(), // Keep as raw JSON string for editing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'youtubeId': youtubeId,
      'category': category,
      'priceCents': (price * 100).toInt(),
      'isActive': isActive,
      'overlayConfig':
          overlayConfig, // string or map? Server expects map usually but let's send what we have
      'placeholderColor': '0xFF000000', // Default
    };
  }

  // Convert to regular Template for preview/compatibility if needed
  Template toTemplate() {
    return Template(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      category: category,
      duration: "0:00", // Not tracked in new model?
      cost: price,
      youtubeId: youtubeId,
    );
  }
}
