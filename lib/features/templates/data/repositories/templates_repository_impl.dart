import '../../domain/models/template.dart';
import '../../domain/repositories/templates_repository.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  @override
  Future<List<Template>> getTemplates() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      const Template(
        id: '1',
        title: 'Royal Heritage',
        description:
            'A traditional Indian wedding invitation with royal motifs and cinematic transitions.',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        category: 'Traditional',
        duration: '0:45',
        isPremium: true,
      ),
      const Template(
        id: '2',
        title: 'Modern Love',
        description:
            'Clean typography and minimalist design for the contemporary couple.',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        category: 'Modern',
        duration: '0:30',
      ),
      const Template(
        id: '3',
        title: 'Floral Grace',
        description:
            'Soft pastel colors and elegant floral animations for a dream wedding.',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        category: 'Minimal',
        duration: '0:40',
        isPremium: true,
      ),
      const Template(
        id: '4',
        title: 'Cinematic Joy',
        description:
            'High-energy edits and vibrant colors for a celebratory invitation.',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        category: 'Modern',
        duration: '0:50',
      ),
    ];
  }

  @override
  Future<List<Template>> getTemplatesByCategory(String category) async {
    final all = await getTemplates();
    return all.where((t) => t.category == category).toList();
  }
}
