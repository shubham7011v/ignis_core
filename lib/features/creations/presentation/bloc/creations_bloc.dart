import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/domain/entities/order.dart';
import 'creations_event.dart';
import 'creations_state.dart';

class CreationsBloc extends Bloc<CreationsEvent, CreationsState> {
  final OrderRepository _orderRepository;
  StreamSubscription? _ordersSubscription;

  CreationsBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(CreationsInitial()) {
    on<LoadUserOrders>(_onLoadUserOrders);
    on<_OrdersUpdated>(_onOrdersUpdated);
    on<_OrdersError>(_onOrdersError);
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrders event,
    Emitter<CreationsState> emit,
  ) async {
    emit(CreationsLoading());
    await _ordersSubscription?.cancel();

    _ordersSubscription = _orderRepository
        .watchUserOrders(event.userId)
        .listen(
          (orders) {
            add(_OrdersUpdated(orders));
          },
          onError: (error) {
            add(_OrdersError(error.toString()));
          },
        );
  }

  void _onOrdersUpdated(_OrdersUpdated event, Emitter<CreationsState> emit) {
    // Cast dynamic list back to List<Order>
    final orders = event.orders.cast<Order>();
    emit(CreationsLoaded(orders: orders));
  }

  void _onOrdersError(_OrdersError event, Emitter<CreationsState> emit) {
    emit(CreationsError(event.message));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _OrdersUpdated extends CreationsEvent {
  final List<dynamic>
  orders; // dynamic to avoid import loop in event file if possible, or just cast
  const _OrdersUpdated(this.orders);
}

class _OrdersError extends CreationsEvent {
  final String message;
  const _OrdersError(this.message);
}
