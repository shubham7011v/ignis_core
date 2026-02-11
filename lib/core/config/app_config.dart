import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

import '../../main_common.dart' show bootStep;

/// Environment-based configuration management
///
/// Usage:
/// 1. Set environment variables before running:
///    flutter run --dart-define=ENV=production --dart-define=SERVER_URL=wss://your-server.com/ws
///
/// 2. Or use .env files with flutter_dotenv package
///
class AppConfig {
  static AppConfig? _instance;

  /// Access global config instance.
  /// Ensure [initialize] is called and awaited before access.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig must be initialized before use. Call await AppConfig.initialize()',
      );
    }
    return _instance!;
  }

  AppConfig._();

  static Future<void> initialize({
    String? env,
    String? appName,
    String? customServerUrl,
    String? customApiUrl,
  }) async {
    final config = AppConfig._();
    _instance = config; // Set instance immediately
    await config._bootstrap(
      injectedEnv: env,
      injectedAppName: appName,
      customServerUrl: customServerUrl,
      customApiUrl: customApiUrl,
    );
  }

  // Custom Overrides
  String? _customServerUrl;
  String? _customApiUrl;

  void load() {
    _load();
  }

  // Environment
  late final String environment;
  late final String appName;
  late final bool isProduction;
  late final bool isDevelopment;

  // Server Configuration
  late final String serverUrl;
  late final String apiBaseUrl;
  late final bool isLocalTesting;
  late final String localIpUrl;
  late final String devVpsUrl;
  late final String productionBaseUrl;

  // Reconnection Settings
  late final int maxReconnectAttempts;
  late final int reconnectBaseDelayMs;

  // Session Settings
  late final int defaultThinkingTimeS;
  late final int defaultPlayerCount;
  late final int maxPlayers;

  // Voice Settings
  late final int voiceTimeoutSeconds;
  late final int voiceSampleRate;

  // Rate Limiting
  late final int maxActionsPerSecond;

  // UI Settings
  late final int animationDurationMs;
  late final int cardDealDelayMs;
  late final int matchmakingDelaySeconds;

  // Development
  late final bool enableLogging;
  late final bool enableDebugMode;
  late List<String> adminUids;
  bool isAdmin = false;

  // Billing & Products
  late final String premiumProductKey;
  late final String premiumPrefKey;

  // Legal & Support
  late final String privacyPolicyUrl;
  late final String termsUrl;
  late final String dataUsageUrl;
  late final String supportEmail;
  late final String helpCenterUrl;
  bool maintenanceMode = false;
  String minAppVersion = '1.0.0';
  String? promoBannerUrl;
  String? appCheckDebugToken;
  String? superAdminEmail;

  // Feature Flags (From Remote Config / Server Override)
  late bool enableVoiceChat;
  late bool enableDailyChallenges;
  late bool enableTournaments;
  late bool enableAdminDashboard;
  late final bool enablePrivateRooms;
  late final bool enableFriendsMatch;
  late final bool enableFriendsMatchOffline;
  late bool enableBotPlayers;
  late bool enableInnerCircle;
  late bool enableGlobalRankings;
  late bool enableEliteDecks;
  late bool enableSessionChat;

  /// Update configuration from dynamic map (Server API or Firestore)
  void updateFromMap(Map<String, dynamic> data) {
    bool isOverridden(String envKey) => _safeGetEnv(envKey) != null;

    // Root properties
    if (data['maintenance_mode'] is bool) {
      maintenanceMode = data['maintenance_mode'];
    }
    if (data['min_app_version'] is String) {
      minAppVersion = data['min_app_version'];
    }
    if (data['promo_banner_url'] is String) {
      promoBannerUrl = data['promo_banner_url'];
    }

    // Support legacy server key names as well
    if (data['maintenanceMode'] is bool) {
      maintenanceMode = data['maintenanceMode'];
    }

    // Nested feature flags or flat list
    final flags = data['feature_flags'] ?? data;
    if (flags is Map<String, dynamic>) {
      if (flags['enableVoiceChat'] is bool &&
          !isOverridden('ENABLE_VOICE_CHAT')) {
        enableVoiceChat = flags['enableVoiceChat'];
      }
      if (flags['enableDailyChallenges'] is bool &&
          !isOverridden('ENABLE_DAILY_CHALLENGES')) {
        enableDailyChallenges = flags['enableDailyChallenges'];
      }
      if (flags['enableTournaments'] is bool &&
          !isOverridden('ENABLE_TOURNAMENTS')) {
        enableTournaments = flags['enableTournaments'];
      }
      if (flags['enableAdminDashboard'] is bool &&
          !isOverridden('ENABLE_ADMIN_DASHBOARD')) {
        enableAdminDashboard = flags['enableAdminDashboard'];
      }
      if (flags['enableSessionChat'] is bool &&
          !isOverridden('ENABLE_SESSION_CHAT')) {
        enableSessionChat = flags['enableSessionChat'];
      }
    }
  }

  /// Legacy method for backend backward compatibility
  void updateFromServer(Map<String, dynamic> serverConfig) =>
      updateFromMap(serverConfig);

  /// Manually override admin status for current user (usually from AUTH_OK websocket)
  void setAdminStatus(bool isAdmin, String uid) {
    this.isAdmin = isAdmin;
    if (isAdmin) {
      if (!adminUids.contains(uid)) {
        adminUids = List<String>.from(adminUids)..add(uid);
      }
      enableAdminDashboard = true;
    }
  }

  Future<void> _bootstrap({
    String? injectedEnv,
    String? injectedAppName,
    String? customServerUrl,
    String? customApiUrl,
  }) async {
    // 1. Try to load .env file
    try {
      await dotenv.load(fileName: ".env");
      AppLogger.info('.env file loaded successfully');
    } catch (e) {
      AppLogger.info('No .env file found or failed to load: $e');
    }

    // 2. Set environment & app name (priority: injected > .env > String.fromEnvironment)
    environment =
        injectedEnv ??
        _safeGetEnv('ENV') ??
        const String.fromEnvironment('ENV', defaultValue: 'development');

    appName =
        injectedAppName ??
        _safeGetEnv('APP_NAME') ??
        const String.fromEnvironment('APP_NAME', defaultValue: 'Vites');

    isProduction = environment == 'production' || environment == 'prod';
    isDevelopment = !isProduction;

    _customServerUrl = customServerUrl;
    _customApiUrl = customApiUrl;
  }

  /// Safely get value from dotenv, returning null
  static String? _safeGetEnv(String key) {
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }

  void _load() {
    // Server Configuration
    bootStep = '4a. Loading Server URLs';
    isLocalTesting = _getBoolConfig(
      'is_local_testing',
      'IS_LOCAL_TESTING',
      false,
    );
    localIpUrl = _getStringConfig(
      'local_ip_url',
      'LOCAL_IP_URL',
      'http://192.168.1.100:8080',
    );
    devVpsUrl = _getStringConfig(
      'dev_vps_url',
      'DEV_VPS_URL',
      'https://dev.vites.iamsorry.in',
    );
    productionBaseUrl = _getStringConfig(
      'production_base_url',
      'PRODUCTION_BASE_URL',
      'https://api.iamsorry.in',
    );

    if (isProduction) {
      serverUrl =
          _customServerUrl ??
          _safeGetEnv('SERVER_URL') ??
          const String.fromEnvironment(
            'SERVER_URL',
            defaultValue: 'wss://vites.iamsorry.in/ws',
          );
      apiBaseUrl =
          _customApiUrl ??
          _safeGetEnv('API_URL') ??
          const String.fromEnvironment(
            'API_URL',
            defaultValue:
                'https://vites.iamsorry.in', // Corrected to match ApiConfig
          );
    } else {
      var defaultServerUrl =
          _customServerUrl ??
          _safeGetEnv('SERVER_URL') ??
          const String.fromEnvironment(
            'SERVER_URL',
            defaultValue: 'wss://dev.vites.iamsorry.in/ws',
          );
      var defaultApiUrl =
          _customApiUrl ??
          _safeGetEnv('API_URL') ??
          (isLocalTesting ? localIpUrl : devVpsUrl);

      // Handle Android Emulator localhost (10.0.2.2)
      if (!kIsWeb && Platform.isAndroid) {
        if (defaultServerUrl.contains('localhost')) {
          defaultServerUrl = defaultServerUrl.replaceFirst(
            'localhost',
            '10.0.2.2',
          );
        }
        if (defaultApiUrl.contains('localhost')) {
          defaultApiUrl = defaultApiUrl.replaceFirst('localhost', '10.0.2.2');
        }
      }

      serverUrl = defaultServerUrl;
      apiBaseUrl = defaultApiUrl;
    }

    // Reconnection Settings
    bootStep = '4b. Loading Reconnection Settings';
    maxReconnectAttempts = _getIntConfig(
      'max_reconnect_attempts',
      'MAX_RECONNECT_ATTEMPTS',
      5,
    );
    reconnectBaseDelayMs = _getIntConfig(
      'reconnect_base_delay_ms',
      'RECONNECT_BASE_DELAY_MS',
      2000,
    );

    // Session Settings
    bootStep = '4c. Loading Session Settings';
    defaultThinkingTimeS = _getIntConfig(
      'default_thinking_time_s',
      'DEFAULT_THINKING_TIME_S',
      10,
    );
    defaultPlayerCount = const int.fromEnvironment(
      'DEFAULT_PLAYER_COUNT',
      defaultValue: 5,
    );
    maxPlayers = _getIntConfig('max_players', 'MAX_PLAYERS', 8);

    // Voice Settings
    bootStep = '4d. Loading Voice Settings';
    voiceTimeoutSeconds = _getIntConfig(
      'voice_timeout_seconds',
      'VOICE_TIMEOUT_SECONDS',
      30,
    );
    voiceSampleRate = const int.fromEnvironment(
      'VOICE_SAMPLE_RATE',
      defaultValue: 48000,
    );

    // Rate Limiting
    bootStep = '4e. Loading Rate Limiting';
    maxActionsPerSecond = _getIntConfig(
      'max_actions_per_second',
      'MAX_ACTIONS_PER_SECOND',
      10,
    );

    // UI Settings
    bootStep = '4f. Loading UI Settings';
    animationDurationMs = const int.fromEnvironment(
      'ANIMATION_DURATION_MS',
      defaultValue: 300,
    );
    cardDealDelayMs = const int.fromEnvironment(
      'CARD_DEAL_DELAY_MS',
      defaultValue: 100,
    );
    matchmakingDelaySeconds = _getIntConfig(
      'matchmaking_delay_seconds',
      'MATCHMAKING_DELAY_SECONDS',
      1,
    );

    // Development
    bootStep = '4g. Loading Development Settings';
    enableLogging = const bool.fromEnvironment(
      'ENABLE_LOGGING',
      defaultValue: kDebugMode,
    );
    enableDebugMode = const bool.fromEnvironment(
      'DEBUG',
      defaultValue: kDebugMode,
    );

    // Billing & Products
    premiumProductKey = _getStringConfig(
      'premium_product_key',
      'PREMIUM_PRODUCT_KEY',
      'premium_templates_pack',
    );
    premiumPrefKey = _getStringConfig(
      'premium_pref_key',
      'PREMIUM_PREF_KEY',
      'is_premium_user',
    );

    // Admin Configuration
    bootStep = '4h. Loading Admin UIDs';
    adminUids = _getStringListConfig('admin_uids', 'ADMIN_UIDS', []);

    // Legal & Support URLs
    bootStep = '4i. Loading Legal URLs';
    privacyPolicyUrl = _getStringConfig(
      'privacy_policy_url',
      'PRIVACY_POLICY_URL',
      'https://example.com/privacy',
    );
    termsUrl = _getStringConfig(
      'terms_url',
      'TERMS_URL',
      'https://example.com/terms',
    );
    dataUsageUrl = _getStringConfig(
      'data_usage_url',
      'DATA_USAGE_URL',
      'https://example.com/data-usage',
    );
    supportEmail = _getStringConfig(
      'support_email',
      'SUPPORT_EMAIL',
      'support@example.com',
    );
    helpCenterUrl = _getStringConfig(
      'help_center_url',
      'HELP_CENTER_URL',
      'https://example.com/help',
    );
    appCheckDebugToken = _safeGetEnv('FIREBASE_APP_CHECK_DEBUG_TOKEN');
    superAdminEmail = _getStringConfig(
      'super_admin_email',
      'SUPER_ADMIN_EMAIL',
      'shubhamsinh2009@gmail.com',
    );

    // Feature Flags
    bootStep = '4j. Loading Feature Flags';
    enableVoiceChat = _getBoolConfig(
      'enable_voice_chat',
      'ENABLE_VOICE_CHAT',
      false,
    );
    enableDailyChallenges = _getBoolConfig(
      'enable_daily_challenges',
      'ENABLE_DAILY_CHALLENGES',
      false,
    );
    enableTournaments = _getBoolConfig(
      'enable_tournaments',
      'ENABLE_TOURNAMENTS',
      false,
    );
    enableAdminDashboard = _getBoolConfig(
      'enable_admin_dashboard',
      'ENABLE_ADMIN_DASHBOARD',
      true,
    );
    enablePrivateRooms = _getBoolConfig(
      'enable_private_rooms',
      'ENABLE_PRIVATE_ROOMS',
      false,
    );
    enableFriendsMatch = _getBoolConfig(
      'enable_friends_match',
      'ENABLE_FRIENDS_MATCH',
      false,
    );
    enableFriendsMatchOffline = _getBoolConfig(
      'enable_friends_match_offline',
      'ENABLE_FRIENDS_MATCH_OFFLINE',
      false,
    );
    // Forced enabled (Remote Config disabled for this feature)
    enableBotPlayers = true;
    enableInnerCircle = _getBoolConfig(
      'enable_inner_circle',
      'ENABLE_INNER_CIRCLE',
      false,
    );
    enableGlobalRankings = _getBoolConfig(
      'enable_global_rankings',
      'ENABLE_GLOBAL_RANKINGS',
      false,
    );
    enableEliteDecks = _getBoolConfig(
      'enable_elite_decks',
      'ENABLE_ELITE_DECKS',
      false,
    );
    enableSessionChat = _getBoolConfig(
      'enable_session_chat',
      'ENABLE_SESSION_CHAT',
      false,
    );

    bootStep = '4k. Config Logging';
    if (enableLogging) {
      _logConfig();
    }
  }

  void _logConfig() {
    AppLogger.info('=== AppConfig Loaded ===');
    AppLogger.info('Environment: $environment');
    AppLogger.info('Server URL: $serverUrl');
    AppLogger.info('API Base URL: $apiBaseUrl');
    AppLogger.info('Max Reconnect Attempts: $maxReconnectAttempts');
    AppLogger.info('Debug Mode: $enableDebugMode');
    AppLogger.info('=======================');
  }

  int _getIntConfig(String rcKey, String envKey, int defaultValue) {
    // 1. Try .env
    final envFileValue = _safeGetEnv(envKey);
    if (envFileValue != null) return int.tryParse(envFileValue) ?? defaultValue;

    // 2. Try Environment Variable (Build Time)
    return int.fromEnvironment(envKey, defaultValue: defaultValue);
  }

  String _getStringConfig(String rcKey, String envKey, String defaultValue) {
    // 1. Try .env
    final envFileValue = _safeGetEnv(envKey);
    if (envFileValue != null) return envFileValue;

    // 3. Try Environment Variable (Build Time)
    return String.fromEnvironment(envKey, defaultValue: defaultValue);
  }

  bool _getBoolConfig(String rcKey, String envKey, bool defaultValue) {
    // 1. Try .env (Local developer override)
    final envFileValue = _safeGetEnv(envKey);
    if (envFileValue != null) return envFileValue.toLowerCase() == 'true';

    // 2. Try Environment Variable (Build-time override)
    final envValue = bool.fromEnvironment(envKey, defaultValue: false);
    if (envValue) return true;

    // 3. Fallback to default
    return defaultValue;
  }

  List<String> _getStringListConfig(
    String rcKey,
    String envKey,
    List<String> defaultValues,
  ) {
    // 1. Try .env
    final envFileValue = _safeGetEnv(envKey);
    if (envFileValue != null) {
      return envFileValue
          .split(',')
          .map((s) => s.trim())
          .where((u) => u.isNotEmpty)
          .toList();
    }

    // 3. Try Environment Variable (Build Time)
    final envValue = String.fromEnvironment(envKey, defaultValue: '');
    if (envValue.isNotEmpty) {
      return envValue
          .split(',')
          .map((s) => s.trim())
          .where((u) => u.isNotEmpty)
          .toList();
    }

    return defaultValues;
  }

  // Helper method to reload config (useful for testing)
  static Future<void> reload() async {
    _instance = null;
    await AppConfig.initialize();
  }
}
