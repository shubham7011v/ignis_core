import '../../domain/models/template.dart';
import '../../domain/repositories/templates_repository.dart';
import '../template_config.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  @override
  @override
  Future<List<Template>> getTemplates() async {
    // Simulate network delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 500));
    return TemplateConfig.templates;
  }

  @override
  Future<List<Template>> getTemplatesByCategory(String category) async {
    final all = await getTemplates();
    return all.where((t) => t.category == category).toList();
  }
}
