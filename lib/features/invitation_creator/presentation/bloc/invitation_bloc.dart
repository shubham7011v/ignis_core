import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/invitation_repository.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final InvitationRepository _repository;

  InvitationBloc({required InvitationRepository repository})
    : _repository = repository,
      super(InvitationState.initial()) {
    on<InvitationStarted>(_onStarted);
    on<StyleSelected>(_onStyleSelected);
    on<DetailsUpdated>(_onDetailsUpdated);
    on<GenerateVideoRequested>(_onGenerateVideoRequested);
  }

  Future<void> _onStarted(
    InvitationStarted event,
    Emitter<InvitationState> emit,
  ) async {
    emit(state.copyWith(status: InvitationStatus.loading));
    try {
      final styles = await _repository.getAvailableStyles();
      emit(
        state.copyWith(
          status: InvitationStatus.initial,
          availableStyles: styles,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onStyleSelected(StyleSelected event, Emitter<InvitationState> emit) {
    emit(state.copyWith(selectedStyle: event.style));
  }

  void _onDetailsUpdated(DetailsUpdated event, Emitter<InvitationState> emit) {
    emit(state.copyWith(details: event.details));
  }

  Future<void> _onGenerateVideoRequested(
    GenerateVideoRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.selectedStyle == null) return;

    emit(state.copyWith(status: InvitationStatus.generating));
    try {
      final jobId = await _repository.generateInvitationVideo(
        style: state.selectedStyle!,
        details: state.details,
      );
      emit(state.copyWith(status: InvitationStatus.success, jobId: jobId));
    } catch (e) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
