import 'package:equatable/equatable.dart';
import '../../domain/entities/invitation_style.dart';
import '../../domain/entities/wedding_details.dart';

enum InvitationStatus { initial, loading, generating, success, failure }

class InvitationState extends Equatable {
  final InvitationStatus status;
  final List<InvitationStyle> availableStyles;
  final InvitationStyle? selectedStyle;
  final WeddingDetails details;
  final String? jobId;
  final double renderProgress;
  final String? renderOutputPath;
  final String? errorMessage;

  const InvitationState({
    this.status = InvitationStatus.initial,
    this.availableStyles = const [],
    this.selectedStyle,
    required this.details,
    this.jobId,
    this.renderProgress = 0.0,
    this.renderOutputPath,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    availableStyles,
    selectedStyle,
    details,
    jobId,
    renderProgress,
    renderOutputPath,
    errorMessage,
  ];

  InvitationState copyWith({
    InvitationStatus? status,
    List<InvitationStyle>? availableStyles,
    InvitationStyle? selectedStyle,
    WeddingDetails? details,
    String? jobId,
    double? renderProgress,
    String? renderOutputPath,
    String? errorMessage,
  }) {
    return InvitationState(
      status: status ?? this.status,
      availableStyles: availableStyles ?? this.availableStyles,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      details: details ?? this.details,
      jobId: jobId ?? this.jobId,
      renderProgress: renderProgress ?? this.renderProgress,
      renderOutputPath: renderOutputPath ?? this.renderOutputPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory InvitationState.initial() {
    return InvitationState(details: WeddingDetails.empty());
  }
}
