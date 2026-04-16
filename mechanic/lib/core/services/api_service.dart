import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  // ================= MECHANIC LOGIN =================
  static Future<Map<String, dynamic>> mechanicLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mechanic/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mechanicId', data['mechanicId']);
        await prefs.setString('mechanicName', data['name'] ?? 'Mechanic');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', 'mechanic');
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // ================= GET JOBS =================
  static Future<Map<String, dynamic>> getMyJobs(String mechanicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mechanic/jobs/$mechanicId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // ================= UPDATE JOB STATUS =================
  static Future<Map<String, dynamic>> updateJobStatus({
    required String requestId,
    required String status,
    String? paymentMethod,
    List<dynamic>? checklist,
    List<dynamic>? parts,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mechanic/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requestId": requestId,
          "status": status,
          "paymentMethod": paymentMethod,
          "checklist": checklist,
          "parts": parts,
          "description": description,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String?> getMechanicId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mechanicId');
  }

  static Future<String?> getMechanicName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mechanicName');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ================= AI CHAT =================
  static Future<Map<String, dynamic>> chatWithAI(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // ================= TRACKING & ATTENDANCE =================
  static Future<Map<String, dynamic>> updateLocation({
    required String requestId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mechanic/update-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requestId": requestId,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> clockIn(String mechanicId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mechanic/attendance/clock-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"mechanicId": mechanicId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> clockOut(String mechanicId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mechanic/attendance/clock-out'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"mechanicId": mechanicId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= HISTORY & STATS =================
  static Future<Map<String, dynamic>> getJobHistory(String mechanicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mechanic/history/$mechanicId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getMechanicStats(String mechanicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mechanic/stats/$mechanicId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= PROFILE =================
  static Future<Map<String, dynamic>> getMechanicProfile(String mechanicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mechanic/profile/$mechanicId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getAttendanceStatus(String mechanicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mechanic/attendance/status/$mechanicId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= AGENT/GARAGE SELECTION =================
  static Future<Map<String, dynamic>> getAllAgents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all-agents'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<String?> getAgentId() async {
    // This is a placeholder for self-registration context
    // In a real app, this might come from a selected garage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('agentId'); 
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
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}
