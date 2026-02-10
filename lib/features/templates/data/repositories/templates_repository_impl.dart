import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/template.dart';
import '../../domain/repositories/templates_repository.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/app_logger.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  @override
  Future<List<Template>> getTemplates() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.templates));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['templates'] ?? [];
        return data.map((item) => Template.fromJson(item)).toList();
      } else {
        AppLogger.error(
          'TemplatesRepository: Failed to fetch templates (${response.statusCode})',
        );
      }
    } catch (e) {
      AppLogger.error('TemplatesRepository: Fetch exception', exception: e);
    }
    return [];
  }

  @override
  Future<List<Template>> getTemplatesByCategory(String category) async {
    final all = await getTemplates();
    return all.where((t) => t.category == category).toList();
  }
}
