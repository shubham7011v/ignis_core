/// Session-specific constants for animations, timeouts, and layout values.
///
/// These constants define the timing and behavior of session UI elements.
class SessionConstants {
  SessionConstants._(); // Private constructor to prevent instantiation

  // ==================== Animation Durations ====================

  /// Standard animation duration for UI transitions
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);

  /// Fast animation for quick feedback
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// Slow animation for dramatic effects
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// Matchmaking orbit animation duration
  static const Duration matchmakingOrbitDuration = Duration(seconds: 4);

  /// Pulse animation duration for attention
  static const Duration pulseAnimationDuration = Duration(milliseconds: 1500);

  // ==================== Timeouts ====================

  /// Matchmaking timeout (seconds)
  static const int matchmakingTimeoutSeconds = 45;

  /// Warning threshold for matchmaking timeout (seconds)
  static const int matchmakingWarningSeconds = 15;

  /// Turn/Action timeout (seconds)
  static const int turnTimeoutSeconds = 30;

  /// Reconnection timeout (seconds)
  static const int reconnectionTimeoutSeconds = 60;

  // ==================== Layout ====================

  /// Maximum number of participants in a session
  static const int maxParticipants = 5;

  /// Default grid cross-axis count for participants
  static const int participantGridCrossAxisCount = 3;

  /// Avatar size
  static const double avatarSize = 48.0;

  /// Large avatar size
  static const double avatarSizeLarge = 80.0;

  // ==================== UI Constants ====================

  /// Opacity for disabled states
  static const double disabledOpacity = 0.5;

  /// Opacity for semi-transparent overlays
  static const double overlayOpacity = 0.8;

  /// Z-index for floating elements
  static const int floatingZIndex = 100;

  /// Icon size for action buttons
  static const double actionIconSize = 24.0;

  /// Large icon size
  static const double largeIconSize = 48.0;
}
