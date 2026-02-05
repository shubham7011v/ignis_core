import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ordersCollection => _firestore.collection('orders');

  @override
  Future<Order> createOrder(Order order) async {
    // Generate a new ID if not provided or use the one in the model if valid
    final docRef = order.id.isEmpty
        ? _ordersCollection.doc()
        : _ordersCollection.doc(order.id);

    final orderWithId = order.copyWith(id: docRef.id);

    await docRef.set(orderWithId.toMap());
    return orderWithId;
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (doc.exists && doc.data() != null) {
      return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? videoUrl,
    String? thumbnailUrl,
  }) async {
    final updates = <String, dynamic>{'status': status.name};

    if (videoUrl != null) {
      updates['videoUrl'] = videoUrl;
    }

    if (thumbnailUrl != null) {
      updates['thumbnailUrl'] = thumbnailUrl;
    }

    if (status == OrderStatus.delivered) {
      updates['deliveredAt'] = DateTime.now().toIso8601String();
    }

    await _ordersCollection.doc(orderId).update(updates);
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final snapshot = await _ordersCollection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map<Order>((doc) {
      return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  @override
  Stream<List<Order>> watchAllOrders({bool descending = true}) {
    return _ordersCollection
        .orderBy('createdAt', descending: descending)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map<Order>((doc) {
            return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  @override
  Stream<List<Order>> watchUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map<Order>((doc) {
            return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
}
