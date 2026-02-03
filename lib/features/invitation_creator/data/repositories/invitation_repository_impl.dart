import '../../domain/entities/invitation_style.dart';
import '../../domain/entities/wedding_details.dart';
import '../../domain/repositories/invitation_repository.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  @override
  Future<List<InvitationStyle>> getAvailableStyles() async {
    // Mocking server response for now
    await Future.delayed(const Duration(seconds: 1));
    return const [
      InvitationStyle(
        id: '1',
        name: 'Royal Heritage',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=400',
        videoTemplateId: 'dQw4w9WgXcQ', // Placeholder
        categories: ['Traditional', 'Gold', 'Premium'],
      ),
      InvitationStyle(
        id: '2',
        name: 'Vintage Bollywood',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=400',
        videoTemplateId: 'dQw4w9WgXcQ', // Placeholder
        categories: ['Cinematic', 'Retro', 'Vibrant'],
      ),
      InvitationStyle(
        id: '3',
        name: 'Modern Minimal',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1544928147-79a2dbc1f389?auto=format&fit=crop&q=80&w=400',
        videoTemplateId: 'dQw4w9WgXcQ', // Placeholder
        categories: ['Clean', 'Elegant', 'Pastel'],
      ),
    ];
  }

  @override
  Future<String> generateInvitationVideo({
    required InvitationStyle style,
    required WeddingDetails details,
  }) async {
    // Stubbing API call
    await Future.delayed(const Duration(seconds: 3));
    return 'job_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> getGenerationStatus(String jobId) async {
    return 'completed';
  }
}
