import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/guest.dart';
import '../../domain/repositories/guests_repository.dart';
import 'guests_event.dart';
import 'guests_state.dart';

class GuestsBloc extends Bloc<GuestsEvent, GuestsState> {
  final GuestsRepository _repository;
  final _uuid = const Uuid();

  GuestsBloc({required GuestsRepository repository})
    : _repository = repository,
      super(GuestsInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<AddGuest>(_onAddGuest);
    on<UpdateGuestRsvp>(_onUpdateRsvp);
    on<RemoveGuestEvent>(_onRemoveGuest);
  }

  Future<void> _onLoadGuests(
    LoadGuests event,
    Emitter<GuestsState> emit,
  ) async {
    emit(GuestsLoading());
    try {
      final guests = await _repository.getGuests();
      emit(GuestsLoaded(guests: guests, stats: _calculateStats(guests)));
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onAddGuest(AddGuest event, Emitter<GuestsState> emit) async {
    try {
      final newGuest = Guest(
        id: _uuid.v4(),
        name: event.name,
        phoneNumber: event.phoneNumber,
      );
      await _repository.addGuest(newGuest);
      add(LoadGuests());
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onUpdateRsvp(
    UpdateGuestRsvp event,
    Emitter<GuestsState> emit,
  ) async {
    try {
      if (state is GuestsLoaded) {
        final currentGuests = (state as GuestsLoaded).guests;
        final index = currentGuests.indexWhere((g) => g.id == event.guestId);
        if (index != -1) {
          final updatedGuest = currentGuests[index].copyWith(
            rsvpStatus: event.status,
          );
          await _repository.updateGuest(updatedGuest);
          add(LoadGuests());
        }
      }
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onRemoveGuest(
    RemoveGuestEvent event,
    Emitter<GuestsState> emit,
  ) async {
    try {
      await _repository.removeGuest(event.guestId);
      add(LoadGuests());
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Map<RsvpStatus, int> _calculateStats(List<Guest> guests) {
    final stats = {
      RsvpStatus.pending: 0,
      RsvpStatus.accepted: 0,
      RsvpStatus.declined: 0,
    };
    for (var guest in guests) {
      stats[guest.rsvpStatus] = (stats[guest.rsvpStatus] ?? 0) + 1;
    }
    return stats;
  }
}
