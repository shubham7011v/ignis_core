import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order.dart';

abstract class CreationsState extends Equatable {
  const CreationsState();

  @override
  List<Object> get props => [];
}

class CreationsInitial extends CreationsState {}

class CreationsLoading extends CreationsState {}

class CreationsLoaded extends CreationsState {
  final List<Order> orders;

  const CreationsLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class CreationsError extends CreationsState {
  final String message;

  const CreationsError(this.message);

  @override
  List<Object> get props => [message];
}
