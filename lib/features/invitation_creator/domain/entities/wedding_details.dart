import 'package:equatable/equatable.dart';

class WeddingDetails extends Equatable {
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String venue;
  final String? customMessage;

  const WeddingDetails({
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.venue,
    this.customMessage,
  });

  @override
  List<Object?> get props => [
    brideName,
    groomName,
    weddingDate,
    venue,
    customMessage,
  ];

  WeddingDetails copyWith({
    String? brideName,
    String? groomName,
    DateTime? weddingDate,
    String? venue,
    String? customMessage,
  }) {
    return WeddingDetails(
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      weddingDate: weddingDate ?? this.weddingDate,
      venue: venue ?? this.venue,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  factory WeddingDetails.empty() {
    return WeddingDetails(
      brideName: '',
      groomName: '',
      weddingDate: DateTime.now(),
      venue: '',
    );
  }
}
