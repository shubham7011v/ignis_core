import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-based configuration management
class AppConfig {
  static AppConfig? _instance;

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
    _instance = config;
    await config._bootstrap(
      injectedEnv: env,
      injectedAppName: appName,
      customServerUrl: customServerUrl,
      customApiUrl: customApiUrl,
    );
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

  /// Update configuration from dynamic map (Server API or Sheets Sync)
  void updateFromMap(Map<String, dynamic> data) {
    if (data['maintenance_mode'] is bool) {
      maintenanceMode = data['maintenance_mode'];
    }
    if (data['min_app_version'] is String) {
      minAppVersion = data['min_app_version'];
    }
    if (data['promo_banner_url'] is String) {
      promoBannerUrl = data['promo_banner_url'];
    }
  }

  Future<void> _bootstrap({
    String? injectedEnv,
    String? injectedAppName,
    String? customServerUrl,
    String? customApiUrl,
  }) async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}

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

    _load(customServerUrl, customApiUrl);
  }

  static String? _safeGetEnv(String key) {
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }

  void _load(String? customServerUrl, String? customApiUrl) {
    isLocalTesting = _getBoolConfig(
      'is_local_testing',
      'IS_LOCAL_TESTING',
      false,
    );
    localIpUrl = _getStringConfig(
      'local_ip_url',
      'LOCAL_IP_URL',
      'http://10.0.2.2:8080',
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
          customServerUrl ??
          _safeGetEnv('SERVER_URL') ??
          'wss://vites.iamsorry.in/ws';
      apiBaseUrl =
          customApiUrl ?? _safeGetEnv('API_URL') ?? 'https://vites.iamsorry.in';
    } else {
      var defaultServerUrl =
          customServerUrl ??
          _safeGetEnv('SERVER_URL') ??
          'wss://dev.vites.iamsorry.in/ws';
      var defaultApiUrl =
          customApiUrl ??
          _safeGetEnv('API_URL') ??
          (isLocalTesting ? localIpUrl : devVpsUrl);

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
  }

  String _getStringConfig(String rcKey, String envKey, String defaultValue) {
    final envFileValue = _safeGetEnv(envKey);
    if (envFileValue != null) return envFileValue;
    return String.fromEnvironment(envKey, defaultValue: defaultValue);
  }

  bool _getBoolConfig(String rcKey, String envKey, bool defaultValue) {
    final envFileValue = _safeGetEnv(envKey);
    if (envFileValue != null) return envFileValue.toLowerCase() == 'true';
    return bool.fromEnvironment(envKey, defaultValue: defaultValue);
  }
}
