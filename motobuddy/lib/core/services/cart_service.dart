import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'user_cart';

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_cartKey);
    if (cartData == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(cartData));
  }

  static Future<void> addToCart(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> cart = await getCartItems();
    
    // Check if exists
    int existingIndex = cart.indexWhere((item) => item['_id'] == product['_id']);
    if (existingIndex >= 0) {
      cart[existingIndex]['quantity'] = (cart[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      product['quantity'] = 1;
      cart.add(product);
    }
    
    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  static Future<void> removeFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> cart = await getCartItems();
    cart.removeWhere((item) => item['_id'] == productId);
    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
