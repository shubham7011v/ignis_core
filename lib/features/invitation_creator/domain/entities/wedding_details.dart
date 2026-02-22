import 'package:equatable/equatable.dart';

class WeddingDetails extends Equatable {
  final String brideName;
  final String groomName;
  final DateTime? weddingDate;
  final String venue;
  final String? customMessage;
  final String? photosLink;
  final String inputType; // 'manual' or 'card'
  final List<Map<String, String>> events;

  const WeddingDetails({
    this.brideName = '',
    this.groomName = '',
    this.weddingDate,
    this.venue = '',
    this.customMessage,
    this.photosLink,
    this.inputType = 'card', // Default to card for the new flow
    this.events = const [],
  });

  @override
  List<Object?> get props => [
    brideName,
    groomName,
    weddingDate,
    venue,
    customMessage,
    photosLink,
    inputType,
    events,
  ];

  WeddingDetails copyWith({
    String? brideName,
    String? groomName,
    DateTime? weddingDate,
    String? venue,
    String? customMessage,
    String? photosLink,
    String? inputType,
    List<Map<String, String>>? events,
  }) {
    return WeddingDetails(
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      weddingDate: weddingDate ?? this.weddingDate,
      venue: venue ?? this.venue,
      customMessage: customMessage ?? this.customMessage,
      photosLink: photosLink ?? this.photosLink,
      inputType: inputType ?? this.inputType,
      events: events ?? this.events,
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
