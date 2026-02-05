import '../../domain/entities/short.dart';
import '../../domain/repositories/shorts_repository.dart';

/// Mock implementation of ShortsRepository
/// TODO: Replace with Firebase/API implementation in backend phase
class MockShortsRepository implements ShortsRepository {
  final Set<String> _favoriteIds = {};

  @override
  Future<List<Short>> getShorts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const Short(
        id: 'short_1',
        title: 'Royal Heritage Wedding',
        category: 'Traditional • Premium',
        placeholderColor: 0xFF3E2723,
      ),
      const Short(
        id: 'short_2',
        title: 'Modern Minimalist',
        category: 'Contemporary • Popular',
        placeholderColor: 0xFF1A237E,
      ),
      const Short(
        id: 'short_3',
        title: 'Golden Haldi Ceremony',
        category: 'Sangeet • Trending',
        placeholderColor: 0xFFF57F17,
      ),
    ];
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
