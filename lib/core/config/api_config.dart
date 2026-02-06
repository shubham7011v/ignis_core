class ApiConfig {
  // Set to true for local testing, false for production
  static const bool isLocalTesting = true;

  // Local URLs for different platforms
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080';
  static const String iosSimulatorUrl = 'http://localhost:8080';
  static const String physicalDeviceUrl =
      'http://192.168.1.x:8080'; // Update with your PC's IP

  // Production URL
  static const String productionBaseUrl = 'https://api.iamsorry.in';

  // Auto-detect platform and return appropriate URL
  static String get baseUrl {
    if (!isLocalTesting) return productionBaseUrl;

    // For local testing, default to Android Emulator
    // Update this based on your testing device
    return androidEmulatorUrl;
  }

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
