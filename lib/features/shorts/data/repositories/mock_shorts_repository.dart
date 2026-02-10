import '../../domain/entities/short.dart';
import '../../domain/repositories/shorts_repository.dart';
import '../../../templates/data/template_config.dart';

/// Mock implementation of ShortsRepository
/// TODO: Replace with Firebase/API implementation in backend phase
class MockShortsRepository implements ShortsRepository {
  final Set<String> _favoriteIds = {};

  @override
  Future<List<Short>> getShorts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate Shorts dynamically from TemplateConfig
    // limit to first 5 or specific ones for the feed
    return TemplateConfig.templates.map((template) {
      // Deterministic pseudo-random color based on title length
      final color = 0xFF000000 | (template.title.hashCode & 0xFFFFFF);

      return Short(
        id: 'short_${template.id}',
        title: template.title,
        category:
            '${template.category} • ${template.cost > 0 ? "Premium" : "Free"}',
        placeholderColor: color,
        templateId: template.id,
        videoUrl: template.videoUrl,
        thumbnailUrl: template.thumbnailUrl,
      );
    }).toList();
  }

  @override
  Future<void> toggleFavorite(String shortId, bool isFavorite) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (isFavorite) {
      _favoriteIds.add(shortId);
    } else {
      _favoriteIds.remove(shortId);
    }
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    return Set.from(_favoriteIds);
  }
}
