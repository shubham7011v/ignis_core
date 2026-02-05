import '../entities/order.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  /// Stream of orders for a specific user
  Stream<List<Order>> watchUserOrders(String userId);

  /// Stream of all orders (Admin only)
  /// Optionally sort by created date
  Stream<List<Order>> watchAllOrders({bool descending = true});

  /// Create a new order
  Future<Order> createOrder(Order order);

  /// Update order status // Admin methods
  Future<List<Order>> getAllOrders();
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? videoUrl,
    String? thumbnailUrl,
  });

  /// Get a single order by ID
  Future<Order?> getOrder(String orderId);
}
