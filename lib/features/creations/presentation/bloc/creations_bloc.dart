import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/creations_repository.dart';
import 'creations_event.dart';
import 'creations_state.dart';

class CreationsBloc extends Bloc<CreationsEvent, CreationsState> {
  final CreationsRepository _repository;

  CreationsBloc({required CreationsRepository repository})
    : _repository = repository,
      super(CreationsInitial()) {
    on<LoadCreations>(_onLoadCreations);
    on<DeleteCreationEvent>(_onDeleteCreation);
  }

  Future<void> _onLoadCreations(
    LoadCreations event,
    Emitter<CreationsState> emit,
  ) async {
    emit(CreationsLoading());
    try {
      final creations = await _repository.getCreations();
      emit(CreationsLoaded(creations: creations));
    } catch (e) {
      emit(CreationsError(e.toString()));
    }
  }

  Future<void> _onDeleteCreation(
    DeleteCreationEvent event,
    Emitter<CreationsState> emit,
  ) async {
    try {
      await _repository.deleteCreation(event.id);
      add(LoadCreations());
    } catch (e) {
      emit(CreationsError(e.toString()));
    }
  }
}
