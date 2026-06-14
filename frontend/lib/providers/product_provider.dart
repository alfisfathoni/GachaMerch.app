import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Dynamic Base URL selection to prevent connection errors
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

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      final data = jsonDecode(response.body);
      if (data is List) {
        _products = data.map((item) => Product.fromJson(item)).toList();
        _errorMessage = '';
      } else if (data is Map && data['success'] == true) {
        _products = (data['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load products: Invalid format';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single product by ID — returns fresh [Product] or null on error.
  Future<Product?> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == true && decoded['data'] != null) {
          return Product.fromJson(decoded['data'] as Map<String, dynamic>);
        } else if (decoded['id'] != null) {
          // Direct object response
          return Product.fromJson(decoded);
        }
      } else if (decoded is Map) {
        final data = Map<String, dynamic>.from(decoded);
        if (data['success'] == true && data['data'] != null) {
          return Product.fromJson(Map<String, dynamic>.from(data['data']));
        } else if (data['id'] != null) {
          // Direct object response
          return Product.fromJson(data);
        }
      }
    } catch (_) {
      // Return null silently — caller handles fallback
    }
    return null;
  }

  Future<Map<String, dynamic>> createProduct({
    required String token,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String imageUrl = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category': category,
          'image_url': imageUrl,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) await fetchProducts();
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required String token,
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String imageUrl = '',
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category': category,
          'image_url': imageUrl,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) await fetchProducts();
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteProduct({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) await fetchProducts();
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> buyProduct({
    required String token,
    required int id,
    required int quantity,
    required String paymentMethod,
    required String uid,
    required String server,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/buy/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'quantity': quantity,
          'paymentMethod': paymentMethod,
          'uid': uid,
          'server': server,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) await fetchProducts();
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
