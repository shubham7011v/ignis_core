import 'package:equatable/equatable.dart';

abstract class ShortsEvent extends Equatable {
  const ShortsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all shorts
class LoadShorts extends ShortsEvent {
  const LoadShorts();
}

/// Event to toggle favorite status
class ToggleFavoriteShort extends ShortsEvent {
  final String shortId;

  const ToggleFavoriteShort(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

/// Event to share a short
class ShareShort extends ShortsEvent {
  final String shortId;

  const ShareShort(this.shortId);

  @override
  List<Object?> get props => [shortId];
}
