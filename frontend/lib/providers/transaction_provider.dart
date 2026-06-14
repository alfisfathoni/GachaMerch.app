import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<AppTransaction> _transactions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<AppTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://192.168.1.5:3000/api';
  }

  /// POST /api/transactions — checkout, saves to DB, returns newBalance
  Future<Map<String, dynamic>> createTransaction({
    required String token,
    required int productId,
    required int quantity,
    required String paymentMethod,
    required String uid,
    required String server,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
          'paymentMethod': paymentMethod,
          'uid': uid,
          'server': server,
        }),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// GET /api/transactions/user/:id — fetch all transactions for a user
  Future<void> fetchTransactions({
    required String token,
    required int userId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (data is List) {
        _transactions = data
            .map((item) => AppTransaction.fromJson(item as Map<String, dynamic>))
            .toList();
        _errorMessage = '';
      } else if (data is Map && data['success'] == false) {
        _errorMessage = data['message'] ?? 'Failed to load transactions';
      } else {
        _errorMessage = 'Unexpected response format';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearTransactions() {
    _transactions = [];
    _errorMessage = '';
    notifyListeners();
  }
}
