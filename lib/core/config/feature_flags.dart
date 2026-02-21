import 'app_config.dart';

/// Feature flags for enabling/disabling app features
class FeatureFlags {
  static AppConfig get _config => AppConfig.instance;

  /// Maintenance Mode
  static bool get isMaintenanceMode => _config.maintenanceMode;

  /// Development Mode
  static bool get isDevelopment => _config.isDevelopment;

  /// Production Mode
  static bool get isProduction => _config.isProduction;

  // Most other flags (VoiceChat, Tournaments, etc.) are currently disabled
  // or hardcoded to false as the app focus is purely on Wedding Invitations.
  static const bool enableVoiceChat = false;
  static const bool enableDailyChallenges = false;
  static const bool enableTournaments = false;
  static const bool enableAdminDashboard = false;
  static const bool enablePrivateRooms = false;
  static const bool enableFriendsMatch = false;
  static const bool enableFriendsMatchOffline = false;
  static const bool enableBotPlayers = false;
  static const bool enableInnerCircle = false;
  static const bool enableGlobalRankings = false;
  static const bool enableEliteDecks = false;
  static const bool enableSessionChat = false;
}
