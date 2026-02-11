import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/config/app_config.dart';
import 'models/admin_user.dart';
import 'models/admin_template.dart';
import '../../orders/domain/entities/order.dart';
import '../../orders/domain/entities/order_status.dart';

class AdminRepository {
  // Base URL from config
  String get _baseUrl {
    return AppConfig.instance.apiBaseUrl;
  }

  // Returns headers with Firebase ID Token and App Check Token
  Future<Map<String, String>> _getAuthHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final token = await user.getIdToken();
    if (token == null) throw Exception('Failed to get ID token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    return headers;
  }

  Future<Map<String, dynamic>> getStats() async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/stats';
    AppLogger.info('🚀 [ADMIN] Fetching Stats... ($url)');

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      AppLogger.error(
        'Failed to load stats (${response.statusCode}): ${response.body}',
      );
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  Future<List<Order>> getOrders() async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/orders';
    AppLogger.info('🚀 [ADMIN] Fetching Orders... ($url)');

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Determine if the response is a direct list or wrapped in { "orders": [...] }
      // The backend usually wraps it. Let's assume standard API wrapping.
      List<dynamic> ordersJson;
      if (data is Map && data.containsKey('orders')) {
        ordersJson = data['orders'];
      } else if (data is List) {
        ordersJson = data;
      } else {
        ordersJson = [];
      }

      return ordersJson.map((json) {
        // Ensure ID is present if it's missing from the map (though it should be there)
        return Order.fromMap(json, json['id'] ?? '');
      }).toList();
    } else {
      AppLogger.error(
        'Failed to load orders (${response.statusCode}): ${response.body}',
      );
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? videoUrl,
  }) async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/orders/$orderId';
    AppLogger.info('🚀 [ADMIN] Updating Order Status... ($url)');

    final body = {'status': status.name, 'videoUrl': videoUrl}
      ..removeWhere((key, value) => value == null);

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      AppLogger.error(
        'Failed to update order (${response.statusCode}): ${response.body}',
      );
      throw Exception('Failed to update order: ${response.statusCode}');
    }
  }

  Future<List<AdminUser>> getUsers({int limit = 50, int offset = 0}) async {
    final headers = await _getAuthHeaders();
    final url =
        '$_baseUrl/admin/users?limit=$limit&offset=$offset'; // Server support for query params needed

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> usersJson = data['users'] ?? [];
      return usersJson.map((json) => AdminUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<List<AdminTemplate>> getTemplates() async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/templates';

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> templatesJson = data['templates'] ?? [];
      return templatesJson.map((json) => AdminTemplate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load templates: ${response.statusCode}');
    }
  }

  Future<void> createTemplate(AdminTemplate template) async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/templates';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(template.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create template: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> updateTemplate(AdminTemplate template) async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/templates/${template.id}';

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(template.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update template: ${response.statusCode}');
    }
  }

  Future<void> deleteTemplate(String id) async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/templates/$id';

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete template: ${response.statusCode}');
    }
  }

  Future<void> updateConfig(Map<String, dynamic> config) async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/config';
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(config),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update config: ${response.statusCode}');
    }
  }

  // --- Broadcast ---

  Future<void> broadcastMessage(String title, String body) async {
    final headers = await _getAuthHeaders();
    final url = '$_baseUrl/admin/broadcast';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'title': title, 'body': body}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to broadcast: ${response.statusCode}');
    }
  }

  // --- User Management ---

  Future<void> updateUserRole(String userId, {required bool isAdmin}) async {
    final headers = await _getAuthHeaders();
    // Special endpoint for super admin
    final url = '$_baseUrl/admin/users/$userId/role';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'isAdmin': isAdmin}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update user role: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
