class ApiConfig {
  static const bool isLocalTesting = true;

  static const String localBaseUrl = 'http://10.0.2.2:8080'; // Android Emulator
  // For iOS Simulator use: http://localhost:8080
  // For Physical Device use your machine IP: http://192.168.x.x:8080

  static const String productionBaseUrl = 'https://api.iamsorry.in';

  static String get baseUrl =>
      isLocalTesting ? localBaseUrl : productionBaseUrl;

  // Endpoints
  static String get authVerify => '$baseUrl/api/auth/verify';
  static String get templates => '$baseUrl/api/templates';
  static String get shorts => '$baseUrl/api/shorts';
  static String get orders => '$baseUrl/api/orders';
}
