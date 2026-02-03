/// Repository interface for wedding session management
abstract class SessionRepository {
  /// Request account deletion from backend
  Future<void> deleteAccount();

  /// Dispose resources
  Future<void> dispose();
}
