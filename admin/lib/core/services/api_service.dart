import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  // ================= ADMIN STATS & REVENUE =================
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/stats'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getCEOReport() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/ceo-report'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> seedFeedback() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/seed-feedback'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getRevenueData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/revenue'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  // ================= MANAGEMENT LISTS =================
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/users'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  static Future<Map<String, dynamic>> getAgents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all-agents'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  static Future<Map<String, dynamic>> getMechanics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all-mechanics'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  // ================= APPROVAL, ASIGNMENT & DELETION =================
  static Future<Map<String, dynamic>> approve(String type, String id, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/approve/$type'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"id": id, "status": status}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  static Future<Map<String, dynamic>> assignMechanic(String mechanicId, String agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/assign-mechanic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"mechanicId": mechanicId, "agentId": agentId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  static Future<Map<String, dynamic>> deleteEntry(String type, String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/admin/delete/$type/$id'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }
  
  static Future<Map<String, dynamic>> getAllRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all-requests'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is allowed."};
    }
  }

  // ================= AUTH =================
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdminLoggedIn', true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdminLoggedIn') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
