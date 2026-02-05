import 'package:equatable/equatable.dart';
import '../../../../features/invitation_creator/domain/entities/wedding_details.dart';
import 'order_status.dart';
import 'payment_info.dart';

class Order extends Equatable {
  final String id;
  final String userId;
  final String styleId;
  final WeddingDetails details;
  final OrderStatus status;
  final String? videoUrl; // YouTube URL
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? adminNotes;
  final PaymentInfo? paymentInfo;

  const Order({
    required this.id,
    required this.userId,
    required this.styleId,
    required this.details,
    this.status = OrderStatus.pending,
    this.videoUrl,
    this.thumbnailUrl,
    required this.createdAt,
    this.deliveredAt,
    this.adminNotes,
    this.paymentInfo,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? styleId,
    WeddingDetails? details,
    OrderStatus? status,
    String? videoUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? adminNotes,
    PaymentInfo? paymentInfo,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      styleId: styleId ?? this.styleId,
      details: details ?? this.details,
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      adminNotes: adminNotes ?? this.adminNotes,
      paymentInfo: paymentInfo ?? this.paymentInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'styleId': styleId,
      'brideName': details.brideName,
      'groomName': details.groomName,
      'weddingDate': details.weddingDate.toIso8601String(),
      'venue': details.venue,
      'customMessage': details.customMessage,
      'status': status.name,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'adminNotes': adminNotes,
      'paymentInfo': paymentInfo?.toMap(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      styleId: map['styleId'] ?? '',
      details: WeddingDetails(
        brideName: map['brideName'] ?? '',
        groomName: map['groomName'] ?? '',
        weddingDate:
            DateTime.tryParse(map['weddingDate'] ?? '') ?? DateTime.now(),
        venue: map['venue'] ?? '',
        customMessage: map['customMessage'],
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      videoUrl: map['videoUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.tryParse(map['deliveredAt'])
          : null,
      adminNotes: map['adminNotes'],
      paymentInfo: map['paymentInfo'] != null
          ? PaymentInfo.fromMap(map['paymentInfo'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    styleId,
    details,
    status,
    videoUrl,
    thumbnailUrl,
    createdAt,
    deliveredAt,
    adminNotes,
    paymentInfo,
  ];
}
