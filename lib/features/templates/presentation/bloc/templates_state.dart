import 'package:equatable/equatable.dart';
import '../../domain/models/template.dart';

abstract class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

class TemplatesInitial extends TemplatesState {}

class TemplatesLoading extends TemplatesState {}

class TemplatesLoaded extends TemplatesState {
  final List<Template> templates;
  final String selectedCategory;

  const TemplatesLoaded({
    required this.templates,
    this.selectedCategory = 'All',
  });

  @override
  List<Object?> get props => [templates, selectedCategory];
}

class TemplatesError extends TemplatesState {
  final String message;
  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}
