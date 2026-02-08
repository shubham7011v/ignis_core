import 'app_config.dart';

class ApiConfig {
  // Environmental settings from AppConfig
  static bool get isLocalTesting => AppConfig.instance.isLocalTesting;
  static String get localIpUrl => AppConfig.instance.localIpUrl;
  static String get devVpsUrl => AppConfig.instance.devVpsUrl;
  static String get productionBaseUrl => AppConfig.instance.productionBaseUrl;

  // Auto-detect environment and return appropriate URL
  static String get baseUrl => AppConfig.instance.apiBaseUrl;

  // API Endpoints
  static String get authVerify => '$baseUrl/api/auth/verify';
  static String get templates => '$baseUrl/api/templates';
  static String get templatesById => '$baseUrl/api/templates'; // Append /:id
  static String get shorts => '$baseUrl/api/shorts';
  static String get shortsFavorites => '$baseUrl/api/shorts/favorites';
  static String shortsToggleFavorite(String id) =>
      '$baseUrl/api/shorts/$id/favorite';
  static String get orders => '$baseUrl/api/orders';
  static String ordersById(String id) => '$baseUrl/api/orders/$id';

  // Admin endpoints
  static String get adminOrders => '$baseUrl/api/admin/orders';
  static String adminOrdersById(String id) => '$baseUrl/api/admin/orders/$id';

  // Sharing endpoints
  static String shortLink(String id) => '$baseUrl/s/$id';
  static String templateLink(String id) => '$baseUrl/v/$id';
}
