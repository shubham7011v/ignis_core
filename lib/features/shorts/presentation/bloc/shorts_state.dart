import 'package:equatable/equatable.dart';
import '../../domain/entities/short.dart';

abstract class ShortsState extends Equatable {
  const ShortsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class ShortsInitial extends ShortsState {
  const ShortsInitial();
}

/// Loading state while fetching shorts
class ShortsLoading extends ShortsState {
  const ShortsLoading();
}

/// Loaded state with shorts data
class ShortsLoaded extends ShortsState {
  final List<Short> shorts;
  final Set<String> favoriteIds;

  const ShortsLoaded({required this.shorts, this.favoriteIds = const {}});

  /// Helper to get shorts with updated favorite status
  List<Short> get shortsWithFavorites {
    return shorts.map((short) {
      return short.copyWith(isFavorite: favoriteIds.contains(short.id));
    }).toList();
  }

  ShortsLoaded copyWith({List<Short>? shorts, Set<String>? favoriteIds}) {
    return ShortsLoaded(
      shorts: shorts ?? this.shorts,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  @override
  List<Object?> get props => [shorts, favoriteIds];
}

/// Error state when something goes wrong
class ShortsError extends ShortsState {
  final String message;

  const ShortsError(this.message);

  @override
  List<Object?> get props => [message];
}
