import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/templates_repository.dart';
import 'templates_event.dart';
import 'templates_state.dart';

class TemplatesBloc extends Bloc<TemplatesEvent, TemplatesState> {
  final TemplatesRepository _repository;

  TemplatesBloc({required TemplatesRepository repository})
    : _repository = repository,
      super(TemplatesInitial()) {
    on<TemplateLoadStarted>(_onLoadStarted);
    on<TemplateCategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onLoadStarted(
    TemplateLoadStarted event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(TemplatesLoading());
    try {
      final templates = await _repository.getTemplates();
      emit(TemplatesLoaded(templates: templates));
    } catch (e) {
      emit(TemplatesError(e.toString()));
    }
  }

  Future<void> _onCategoryChanged(
    TemplateCategoryChanged event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(TemplatesLoading());

    try {
      if (event.category == 'All') {
        final templates = await _repository.getTemplates();
        emit(TemplatesLoaded(templates: templates, selectedCategory: 'All'));
      } else {
        final templates = await _repository.getTemplatesByCategory(
          event.category,
        );
        emit(
          TemplatesLoaded(
            templates: templates,
            selectedCategory: event.category,
          ),
        );
      }
    } catch (e) {
      emit(TemplatesError(e.toString()));
    }
  }
}
