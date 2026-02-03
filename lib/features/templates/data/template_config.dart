import '../domain/models/template.dart';

class TemplateConfig {
  /// Hardcoded list of templates for v1.0 MVP
  static const List<Template> templates = [
    Template(
      id: 'royal_maroon_gold',
      title: 'Royal Maroon & Gold',
      thumbnailUrl:
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', // Placeholder
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder
      description:
          'A classic majestic theme with deep maroon and gold accents.',
      isPremium: false,
      category: 'Traditional',
      duration: '0:45',
    ),
    Template(
      id: 'floral_pastel',
      title: 'Floral Pastel Dreams',
      thumbnailUrl:
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', // Placeholder
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder
      description: 'Soft pastel flowers perfect for a daytime ceremony.',
      isPremium: false,
      category: 'Minimal',
      duration: '0:40',
    ),
    Template(
      id: 'modern_minimal_white',
      title: 'Modern Minimal White',
      thumbnailUrl:
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', // Placeholder
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder
      description: 'Clean, crisp white architecture with elegant typography.',
      isPremium: true,
      category: 'Modern',
      duration: '0:30',
    ),
    Template(
      id: 'traditional_red',
      title: 'Traditional Red',
      thumbnailUrl:
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', // Placeholder
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder
      description: 'The quintessential color of love and prosperity.',
      isPremium: true,
      category: 'Traditional',
      duration: '0:50',
    ),
    Template(
      id: 'night_sky',
      title: 'Starry Night Sky',
      thumbnailUrl:
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', // Placeholder
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder
      description: 'A magical evening theme under the stars.',
      isPremium: true,
      category: 'Creative',
      duration: '0:55',
    ),
  ];
}
