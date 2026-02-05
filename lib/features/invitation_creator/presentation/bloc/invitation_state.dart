import 'package:equatable/equatable.dart';
import '../../domain/entities/invitation_style.dart';
import '../../domain/entities/wedding_details.dart';

enum InvitationStatus { initial, loading, placingOrder, success, failure }

class InvitationState extends Equatable {
  final InvitationStatus status;
  final List<InvitationStyle> availableStyles;
  final InvitationStyle? selectedStyle;
  final WeddingDetails details;
  final String? orderId;
  final String? errorMessage;

  const InvitationState({
    this.status = InvitationStatus.initial,
    this.availableStyles = const [],
    this.selectedStyle,
    required this.details,
    this.orderId,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    availableStyles,
    selectedStyle,
    details,
    orderId,
    errorMessage,
  ];

  static const _null = Object();

  InvitationState copyWith({
    InvitationStatus? status,
    List<InvitationStyle>? availableStyles,
    InvitationStyle? selectedStyle,
    WeddingDetails? details,
    Object? orderId = _null,
    Object? errorMessage = _null,
  }) {
    return InvitationState(
      status: status ?? this.status,
      availableStyles: availableStyles ?? this.availableStyles,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      details: details ?? this.details,
      orderId: orderId == _null ? this.orderId : orderId as String?,
      errorMessage: errorMessage == _null
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  factory InvitationState.initial() {
    return InvitationState(details: WeddingDetails.empty());
  }
}
