import '../models/template.dart';

abstract class TemplatesRepository {
  Future<List<Template>> getTemplates();
  Future<List<Template>> getTemplatesByCategory(String category);
}
