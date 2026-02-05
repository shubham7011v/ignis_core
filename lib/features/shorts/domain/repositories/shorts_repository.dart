import '../entities/short.dart';

/// Repository interface for shorts-related operations
abstract class ShortsRepository {
  /// Fetches all available shorts
  Future<List<Short>> getShorts();

  /// Toggles favorite status for a short
  Future<void> toggleFavorite(String shortId, bool isFavorite);

  /// Gets user's favorite shorts
  Future<Set<String>> getFavoriteIds();
}
