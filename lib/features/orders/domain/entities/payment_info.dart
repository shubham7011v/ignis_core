import 'package:equatable/equatable.dart';

class PaymentInfo extends Equatable {
  final String transactionId;
  final double amount;
  final String currency;
  final DateTime paidAt;
  final String status;

  const PaymentInfo({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.paidAt,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'paidAt': paidAt.toIso8601String(),
      'status': status,
    };
  }

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      transactionId: map['transactionId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'INR',
      paidAt: DateTime.tryParse(map['paidAt'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'unknown',
    );
  }

  @override
  List<Object?> get props => [transactionId, amount, currency, paidAt, status];
}
