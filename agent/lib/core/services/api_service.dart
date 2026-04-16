import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 192.168.31.130 for Physical Devices / Web. Use 10.0.2.2 for Android emulators.
  static const String baseUrl = 'http://localhost:5000';

  static Future<Map<String, dynamic>> agentRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String garageName,
    required String address,
    required String pincode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/agent/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "garageName": garageName,
          "address": address,
          "pincode": pincode,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: \$e"};
    }
  }

  static Future<Map<String, dynamic>> agentLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/agent/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('agentId', data['agentId']);
        await prefs.setBool('isLoggedIn', true);
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> getAgentRequests(String agentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/agent/requests/$agentId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> acceptRequest(String requestId, String agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/agent/accept'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"requestId": requestId, "agentId": agentId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> registerMechanic({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String agentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mechanic/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "agentId": agentId,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> getMechanics(String agentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/agent/mechanics/$agentId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String?> getAgentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('agentId');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ================= PRODUCT MANAGEMENT =================
  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double salePrice,
    required String category,
    required String agentId,
    double purchasePrice = 0,
    double? mrp,
    String? sku,
    String? brand,
    String unit = "pcs",
    int reorderLevel = 10,
    int stock = 0,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "description": description,
          "salePrice": salePrice,
          "mrp": mrp ?? salePrice,
          "purchasePrice": purchasePrice,
          "category": category,
          "agentId": agentId,
          "stock": stock,
          "sku": sku,
          "brand": brand,
          "unit": unit,
          "reorderLevel": reorderLevel,
          "image": image,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getGarageProducts(String garageId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/garage/$garageId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/products/$productId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> deleteMechanic(String mechanicId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/mechanic/$mechanicId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> updateStock(String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/update-stock'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"productId": productId, "stock": quantity}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> getMechanicHours(String agentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/agent/mechanics/hours/$agentId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getAgentHistory(String agentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/agent/history/$agentId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateLocation({
    required String requestId,
    required double lat,
    required double lng,
    String? status,
    String? eta,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/service/update-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requestId": requestId,
          "lat": lat,
          "lng": lng,
          "status": status,
          "eta": eta,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> assignMechanic(String requestId, String mechanicId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/agent/assign-mechanic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"requestId": requestId, "mechanicId": mechanicId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getFeedbackSummary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/feedback-summary'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> agentForgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/agent/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getAgentEarnings(String agentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/agent/earnings/$agentId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}
