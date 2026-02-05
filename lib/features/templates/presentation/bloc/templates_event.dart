import 'package:equatable/equatable.dart';

abstract class TemplatesEvent extends Equatable {
  const TemplatesEvent();

  @override
  List<Object?> get props => [];
}

class TemplateLoadStarted extends TemplatesEvent {}

class TemplateCategoryChanged extends TemplatesEvent {
  final String category;
  const TemplateCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchTemplates extends TemplatesEvent {
  final String query;
  const SearchTemplates(this.query);

  @override
  List<Object?> get props => [query];
}
