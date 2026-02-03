import '../../domain/models/creation.dart';
import '../../domain/repositories/creations_repository.dart';

class CreationsRepositoryImpl implements CreationsRepository {
  final List<Creation> _mockCreations = [
    Creation(
      id: 'c1',
      title: 'Our Grand Reception',
      templateId: '1',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Creation(
      id: 'c2',
      title: 'Sangeet Night',
      templateId: '2',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<Creation>> getCreations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_mockCreations);
  }

  @override
  Future<void> deleteCreation(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockCreations.removeWhere((c) => c.id == id);
  }
}
