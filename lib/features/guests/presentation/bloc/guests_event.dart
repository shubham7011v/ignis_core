import 'package:equatable/equatable.dart';
import '../../domain/models/guest.dart';

abstract class GuestsEvent extends Equatable {
  const GuestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGuests extends GuestsEvent {}

class AddGuest extends GuestsEvent {
  final String name;
  final String phoneNumber;
  const AddGuest(this.name, this.phoneNumber);

  @override
  List<Object?> get props => [name, phoneNumber];
}

class UpdateGuestRsvp extends GuestsEvent {
  final String guestId;
  final RsvpStatus status;
  const UpdateGuestRsvp(this.guestId, this.status);

  @override
  List<Object?> get props => [guestId, status];
}

class RemoveGuestEvent extends GuestsEvent {
  final String guestId;
  const RemoveGuestEvent(this.guestId);

  @override
  List<Object?> get props => [guestId];
}
