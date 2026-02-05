import '../domain/models/template.dart';

class TemplateConfig {
  /// Hardcoded list of templates for v1.0 MVP
  static const List<Template> templates = [
    Template(
      id: 'template_royal_maroon',
      title: 'Royal Maroon & Gold',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=600',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      description:
          'A classic majestic theme with deep maroon and gold accents.',
      isPremium: true,
      cost: 499,
      category: 'Traditional',
      duration: '0:45',
      youtubeId: 'dQw4w9WgXcQ',
    ),
    Template(
      id: 'template_floral_pastel',
      title: 'Floral Pastel Dreams',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1520854221256-17451cc331bf?auto=format&fit=crop&q=80&w=600',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      description: 'Soft pastel flowers perfect for a daytime ceremony.',
      isPremium: true,
      cost: 299,
      category: 'Minimal',
      duration: '0:40',
      youtubeId: 'dQw4w9WgXcQ',
    ),
    Template(
      id: 'template_modern_minimal',
      title: 'Modern Minimal White',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=600',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      description: 'Clean, crisp white architecture with elegant typography.',
      isPremium: false,
      cost: 0,
      category: 'Modern',
      duration: '0:30',
      youtubeId: 'dQw4w9WgXcQ',
    ),
    Template(
      id: 'template_traditional_red',
      title: 'Traditional Red',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?auto=format&fit=crop&q=80&w=600',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      description: 'The quintessential color of love and prosperity.',
      isPremium: true,
      cost: 699,
      category: 'Traditional',
      duration: '0:50',
      youtubeId: 'dQw4w9WgXcQ',
    ),
    Template(
      id: 'template_starry_night',
      title: 'Starry Night Sky',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?auto=format&fit=crop&q=80&w=600',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      description: 'A magical evening theme under the stars.',
      isPremium: true,
      cost: 399,
      category: 'Creative',
      duration: '0:55',
      youtubeId: 'dQw4w9WgXcQ',
    ),
  ];
}
