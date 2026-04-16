import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000";
  static final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "vehicleType": vehicleType,
          "vehicleNumber": vehicleNumber,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', data['userId']);
        authNotifier.value = true;
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  // ================= CHAT =================
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"reply": "Connection error"};
    }
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    authNotifier.value = false;
  }

  // ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool('isLoggedIn') ?? false;
    authNotifier.value = status;
    return status;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getToken() async => getUserId();

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = await getUserId();
      if (userId == null) return {"success": false, "message": "Not logged in"};
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/profile/$userId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // ================= BOOK SERVICE =================
  static Future<Map<String, dynamic>> bookService({
    required String serviceType,
    required String vehicleType,
    required String description,
    required String pincode,
    required String serviceMode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final userId = await getUserId();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/service/book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "serviceType": serviceType,
          "vehicleType": vehicleType,
          "description": description,
          "pincode": pincode,
          "serviceMode": serviceMode,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  // ================= UPDATE BOOKING PAYMENT =================
  static Future<Map<String, dynamic>> updateBookingPayment({
    required String bookingId,
    required String method,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/service/update-booking-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "bookingId": bookingId,
          "paymentMethod": method,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // ================= AGENT REGISTER =================
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
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  // ================= AGENT LOGIN =================
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
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('agentId', data['agentId']);
        await prefs.setString('userType', 'agent');
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Connection error: $e. Check if backend is running at $baseUrl and CORS is configured."};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = await getUserId();
      final response = await http.get(Uri.parse('$baseUrl/api/user/profile/$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= BOOKINGS =================
  static Future<Map<String, dynamic>> getCustomerBookings() async {
    try {
      final userId = await getUserId();
      final response = await http.get(Uri.parse('$baseUrl/api/service/customer/$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "bookings": []};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final userId = await getUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "name": name,
          "phone": phone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= VEHICLES =================
  static Future<Map<String, dynamic>> getVehicles() async {
    try {
      final userId = await getUserId();
      final response = await http.get(Uri.parse('$baseUrl/api/vehicles/$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "vehicles": []};
    }
  }

  static Future<Map<String, dynamic>> addVehicle({
    required String type,
    required String brand,
    required String model,
    required String number,
  }) async {
    try {
      final userId = await getUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/api/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "type": type,
          "brand": brand,
          "model": model,
          "number": number,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> deleteVehicle(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/vehicles/$id'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= NEARBY =================
  static Future<Map<String, dynamic>> getNearbyGarages(String pincode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/service/nearby?pincode=$pincode'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "garages": []};
    }
  }

  // ================= TRACKING =================
  static Future<Map<String, dynamic>> getTrackingStatus(String bookingId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/service/status/$bookingId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= SUPPORT =================
  static Future<Map<String, dynamic>> createTicket(String subject, String description) async {
    try {
      final userId = await getUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/api/support/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "subject": subject,
          "description": description,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getTickets() async {
    try {
      final userId = await getUserId();
      final response = await http.get(Uri.parse('$baseUrl/api/support/tickets/$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "tickets": []};
    }
  }

  static Future<Map<String, dynamic>> submitFeedback({
    required String bookingId,
    required double rating,
    required String review,
    String? targetId,
    String? targetType,
  }) async {
    try {
      final userId = await getUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/api/service/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "bookingId": bookingId,
          "rating": rating,
          "review": review,
          "userId": userId,
          "targetId": targetId,
          "targetType": targetType ?? "agent",
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false};
    }
  }

  // ================= PRODUCTS =================
  static Future<Map<String, dynamic>> getAllProducts({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/all?page=$page&limit=$limit'));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "products": []};
    }
  }
  static Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/transactions/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    String? userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final effectiveUserId = userId ?? await getUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": effectiveUserId,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}
