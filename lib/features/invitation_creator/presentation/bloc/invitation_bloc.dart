import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../../domain/entities/invitation_style.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';
import '../../data/services/client_render_service.dart';
import '../../../templates/data/services/template_download_service.dart';
import '../../../templates/domain/models/template.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final InvitationRepository _repository;
  final ClientRenderService _renderService;
  final TemplateDownloadService _downloadService;

  InvitationBloc({
    required InvitationRepository repository,
    required ClientRenderService renderService,
    required TemplateDownloadService downloadService,
  }) : _repository = repository,
       _renderService = renderService,
       _downloadService = downloadService,
       super(InvitationState.initial()) {
    on<InvitationStarted>(_onStarted);
    on<StyleSelected>(_onStyleSelected);
    on<DetailsUpdated>(_onDetailsUpdated);
    on<GenerateVideoRequested>(_onGenerateVideoRequested);
    on<TemplateSelected>(_onTemplateSelected);
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

    emit(
      state.copyWith(status: InvitationStatus.generating, renderProgress: 0.0),
    );

    try {
      // 1. Get/Download Template
      final template = Template(
        id: state.selectedStyle!.id,
        title: state.selectedStyle!.name,
        description: '',
        thumbnailUrl: state.selectedStyle!.thumbnailUrl,
        videoUrl: state.selectedStyle!.videoTemplateId,
        category: state.selectedStyle!.categories.first,
        duration: '0:30',
        youtubeId: state.selectedStyle!.id == '1'
            ? 'dQw4w9WgXcQ'
            : 'dQw4w9WgXcQ',
      );

      final templateFile = await _downloadService.downloadTemplateWithProgress(
        template,
        (progress) {
          emit(state.copyWith(renderProgress: progress * 0.3));
        },
      );

      // 2. Render locally
      final renderResult = await _renderService.renderInvitation(
        templateFile: templateFile,
        details: state.details,
        onProgress: (progress) {
          emit(state.copyWith(renderProgress: 0.3 + (progress * 0.7)));
        },
      );

      if (renderResult.status == RenderStatus.success) {
        emit(
          state.copyWith(
            status: InvitationStatus.success,
            renderOutputPath: renderResult.outputPath,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: InvitationStatus.failure,
            errorMessage: renderResult.errorMessage,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onTemplateSelected(
    TemplateSelected event,
    Emitter<InvitationState> emit,
  ) {
    final style = InvitationStyle(
      id: event.template.id,
      name: event.template.title,
      thumbnailUrl: event.template.thumbnailUrl,
      videoTemplateId: event.template.videoUrl,
      categories: [event.template.category],
    );
    emit(state.copyWith(selectedStyle: style));
  }
}
