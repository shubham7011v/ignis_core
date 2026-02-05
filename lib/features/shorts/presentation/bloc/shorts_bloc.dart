import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/repositories/shorts_repository.dart';
import 'shorts_event.dart';
import 'shorts_state.dart';

class ShortsBloc extends Bloc<ShortsEvent, ShortsState> {
  final ShortsRepository _repository;

  ShortsBloc({required ShortsRepository repository})
    : _repository = repository,
      super(const ShortsInitial()) {
    on<LoadShorts>(_onLoadShorts);
    on<ToggleFavoriteShort>(_onToggleFavorite);
    on<ShareShort>(_onShareShort);
  }

  Future<void> _onLoadShorts(
    LoadShorts event,
    Emitter<ShortsState> emit,
  ) async {
    emit(const ShortsLoading());
    try {
      final shorts = await _repository.getShorts();
      final favoriteIds = await _repository.getFavoriteIds();
      emit(ShortsLoaded(shorts: shorts, favoriteIds: favoriteIds));
    } catch (e) {
      emit(ShortsError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteShort event,
    Emitter<ShortsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ShortsLoaded) return;

    // Optimistic update
    final updatedFavorites = Set<String>.from(currentState.favoriteIds);
    final isNowFavorite = !updatedFavorites.contains(event.shortId);

    if (isNowFavorite) {
      updatedFavorites.add(event.shortId);
    } else {
      updatedFavorites.remove(event.shortId);
    }

    emit(currentState.copyWith(favoriteIds: updatedFavorites));

    try {
      await _repository.toggleFavorite(event.shortId, isNowFavorite);
    } catch (e) {
      // Rollback on error
      emit(currentState);
      emit(ShortsError('Failed to update favorite: ${e.toString()}'));
      // Restore previous state after showing error
      emit(currentState);
    }
  }

  Future<void> _onShareShort(
    ShareShort event,
    Emitter<ShortsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ShortsLoaded) return;

    final short = currentState.shorts.firstWhere(
      (s) => s.id == event.shortId,
      orElse: () => currentState.shorts.first,
    );

    try {
      await Share.share(
        'Check out this amazing wedding invitation template: ${short.title}',
        subject: 'Vivaah - ${short.title}',
      );
    } catch (e) {
      // Share errors are non-critical, just log
      emit(ShortsError('Failed to share: ${e.toString()}'));
      emit(currentState);
    }
  }
}
