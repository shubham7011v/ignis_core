import 'package:equatable/equatable.dart';

abstract class CreationsEvent extends Equatable {
  const CreationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCreations extends CreationsEvent {}

class DeleteCreationEvent extends CreationsEvent {
  final String id;
  const DeleteCreationEvent(this.id);

  @override
  List<Object?> get props => [id];
}
