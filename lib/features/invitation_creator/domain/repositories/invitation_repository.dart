import '../entities/invitation_style.dart';
import '../entities/wedding_details.dart';

abstract class InvitationRepository {
  /// Fetch available invitation styles from the server.
  Future<List<InvitationStyle>> getAvailableStyles();

  /// Start the video generation process on the server.
  /// Returns a job ID or status.
  Future<String> generateInvitationVideo({
    required InvitationStyle style,
    required WeddingDetails details,
  });

  /// Check the status of a video generation job.
  Future<String> getGenerationStatus(String jobId);
}
