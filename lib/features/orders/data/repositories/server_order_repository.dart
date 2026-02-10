import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

class ServerOrderRepository implements OrderRepository {
  final FirebaseAuth _auth;
  final http.Client _client;

  ServerOrderRepository({FirebaseAuth? auth, http.Client? client})
    : _auth = auth ?? FirebaseAuth.instance,
      _client = client ?? http.Client();

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Order> createOrder(Order order) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();

    final response = await _client.post(
      Uri.parse(ApiConfig.orders),
      headers: _getHeaders(token!),
      body: jsonEncode({
        'templateId': order.styleId,
        'brideName': order.details.brideName,
        'groomName': order.details.groomName,
        'weddingDate': order.details.weddingDate.toIso8601String().split(
          'T',
        )[0],
        'venue': order.details.venue,
        'customMessage': order.details.customMessage,
        'amountCents': ((order.paymentInfo?.amount ?? 0) * 100).toInt(),
        'transactionId':
            order.paymentInfo?.transactionId ??
            'manual_${DateTime.now().millisecondsSinceEpoch}',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final orderJson = _processOrderUrl(data['order']);
      return Order.fromMap(orderJson, orderJson['id']);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();
    final response = await _client.get(
      Uri.parse(ApiConfig.ordersById(orderId)),
      headers: _getHeaders(token!),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final orderJson = _processOrderUrl(data['order']);
      return Order.fromMap(orderJson, orderJson['id']);
    }
    return null;
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();
    final response = await _client.get(
      Uri.parse(ApiConfig.orders),
      headers: _getHeaders(token!),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> ordersJson = data['orders'] ?? [];
      return ordersJson
          .map((json) => Order.fromMap(_processOrderUrl(json), json['id']))
          .toList();
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  @override
  Stream<List<Order>> watchAllOrders({bool descending = true}) {
    // For simplicity, we fallback to polling for now or return a one-time stream
    // Real implementation would use WebSockets or SSE
    return Stream.fromFuture(getAllOrders());
  }

  @override
  Stream<List<Order>> watchUserOrders(String userId) {
    return Stream.fromFuture(getAllOrders());
  }

  Map<String, dynamic> _processOrderUrl(Map<String, dynamic> json) {
    String? videoUrl = json['videoUrl'];
    if (videoUrl != null && videoUrl.startsWith('/')) {
      json['videoUrl'] = '${ApiConfig.baseUrl}$videoUrl';
    }
    return json;
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? videoUrl,
    String? thumbnailUrl,
  }) async {
    // User typically doesn't update their own order status manually
    // This would be an Admin action.
    throw UnimplementedError('User cannot update order status directly');
  }
}
