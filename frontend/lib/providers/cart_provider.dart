import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String _token = '';

  List<CartItem> get items => [..._items];

  double get totalAmount {
    var total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  int get itemCount {
    var count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  // Dynamic Base URL selection — mirrors auth_provider.dart and product_provider.dart
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api";
    }
    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 to connect to host's localhost (3000)
        return "http://10.0.2.2:3000/api";
      }
    } catch (e) {
      // Fallback
    }
    // IP Lokal laptop: Ubah IP 192.168.1.5 di bawah ini sesuai hasil command 'ipconfig' di laptop Anda
    return "http://192.168.1.5:3000/api";
  }

  void updateToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  Future<void> fetchCart() async {
    if (_token.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _items = (data['data'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch cart error: $e');
    }
  }

  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    if (_token.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: _headers,
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await fetchCart(); // Refresh items
        return true;
      }
      return false;
    } catch (e) {
      print('Add to cart error: $e');
      return false;
    }
  }

  Future<bool> updateQuantity(int cartItemId, int quantity) async {
    if (_token.isEmpty) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: _headers,
        body: jsonEncode({'quantity': quantity}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final index = _items.indexWhere((item) => item.id == cartItemId);
        if (index >= 0) {
          _items[index].quantity = quantity;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Update quantity error: $e');
      return false;
    }
  }

  Future<bool> removeFromCart(int cartItemId) async {
    if (_token.isEmpty) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _items.removeWhere((item) => item.id == cartItemId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Remove from cart error: $e');
      return false;
    }
  }

  Future<bool> checkout() async {
    if (_token.isEmpty) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _items.clear();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Checkout error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> checkoutCart({
    required String paymentMethod,
    required String uid,
    required String server,
  }) async {
    if (_token.isEmpty) return {'success': false, 'message': 'Authentication token is required'};
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkout/cart'),
        headers: _headers,
        body: jsonEncode({
          'paymentMethod': paymentMethod,
          'uid': uid,
          'server': server,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _items.clear();
        notifyListeners();
        return data;
      }
      return data;
    } catch (e) {
      print('Checkout cart error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
