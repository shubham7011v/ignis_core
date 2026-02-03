import 'package:equatable/equatable.dart';
import '../../domain/models/creation.dart';

abstract class CreationsState extends Equatable {
  const CreationsState();

  @override
  List<Object?> get props => [];
}

class CreationsInitial extends CreationsState {}

class CreationsLoading extends CreationsState {}

class CreationsLoaded extends CreationsState {
  final List<Creation> creations;

  const CreationsLoaded({required this.creations});

  @override
  List<Object?> get props => [creations];
}

class CreationsError extends CreationsState {
  final String message;
  const CreationsError(this.message);

  @override
  List<Object?> get props => [message];
}
