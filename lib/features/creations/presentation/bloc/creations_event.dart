import 'package:equatable/equatable.dart';

abstract class CreationsEvent extends Equatable {
  const CreationsEvent();

  @override
  List<Object> get props => [];
}

class LoadUserOrders extends CreationsEvent {
  final String userId;
  const LoadUserOrders(this.userId);

  @override
  List<Object> get props => [userId];
}

class DeleteOrderEvent extends CreationsEvent {
  final String orderId;
  const DeleteOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}
