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
    on<SearchTemplates>(_onSearchTemplates);
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

  Future<void> _onSearchTemplates(
    SearchTemplates event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(TemplatesLoading());
    try {
      final allTemplates = await _repository.getTemplates();
      if (event.query.isEmpty) {
        emit(TemplatesLoaded(templates: allTemplates));
        return;
      }

      final filtered = allTemplates.where((t) {
        final query = event.query.toLowerCase();
        return t.title.toLowerCase().contains(query) ||
            t.category.displayName.toLowerCase().contains(query);
      }).toList();

      emit(TemplatesLoaded(templates: filtered));
    } catch (e) {
      emit(TemplatesError(e.toString()));
    }
  }
}
