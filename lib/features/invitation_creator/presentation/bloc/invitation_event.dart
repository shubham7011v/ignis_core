import 'package:equatable/equatable.dart';
import '../../domain/entities/invitation_style.dart';
import '../../domain/entities/wedding_details.dart';
import '../../../templates/domain/models/template.dart';

abstract class InvitationEvent extends Equatable {
  const InvitationEvent();

  @override
  List<Object?> get props => [];
}

class InvitationStarted extends InvitationEvent {}

class StyleSelected extends InvitationEvent {
  final InvitationStyle style;
  const StyleSelected(this.style);

  @override
  List<Object?> get props => [style];
}

class DetailsUpdated extends InvitationEvent {
  final WeddingDetails details;
  const DetailsUpdated(this.details);

  @override
  List<Object?> get props => [details];
}

class PlaceOrderRequested extends InvitationEvent {
  final String userId;
  const PlaceOrderRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TemplateSelected extends InvitationEvent {
  final Template template;
  const TemplateSelected(this.template);

  @override
  List<Object?> get props => [template];
}
