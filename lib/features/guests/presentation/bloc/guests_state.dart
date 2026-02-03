import 'package:equatable/equatable.dart';
import '../../domain/models/guest.dart';

abstract class GuestsState extends Equatable {
  const GuestsState();

  @override
  List<Object?> get props => [];
}

class GuestsInitial extends GuestsState {}

class GuestsLoading extends GuestsState {}

class GuestsLoaded extends GuestsState {
  final List<Guest> guests;
  final Map<RsvpStatus, int> stats;

  const GuestsLoaded({required this.guests, this.stats = const {}});

  @override
  List<Object?> get props => [guests, stats];
}

class GuestsError extends GuestsState {
  final String message;
  const GuestsError(this.message);

  @override
  List<Object?> get props => [message];
}
