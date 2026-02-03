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
