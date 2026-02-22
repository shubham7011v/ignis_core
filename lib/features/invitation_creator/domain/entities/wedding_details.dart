import 'package:equatable/equatable.dart';

enum InvitationInputType { manual, card }

class WeddingDetails extends Equatable {
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String venue;
  final String? customMessage;
  final String? photosLink;
  final InvitationInputType inputType;
  final List<Map<String, String>> events;

  const WeddingDetails({
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.venue,
    this.customMessage,
    this.photosLink,
    this.inputType = InvitationInputType.manual,
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
    InvitationInputType? inputType,
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
