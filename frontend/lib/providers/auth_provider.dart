import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider with ChangeNotifier {
  String _token = '';
  bool _isAuthenticated = false;
  String _role = 'user';
  double _balance = 0.0;
  int _userId = 0;

  bool get isAuthenticated => _isAuthenticated;
  String get token => _token;
  String get role => _role;
  double get balance => _balance;
  int get userId => _userId;

  // Dynamic Base URL selection to prevent "kesalahan koneksi" (connection errors)
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

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success' || data['success'] == true) {
        _token = data['token'];
        _isAuthenticated = true;
        _role = data['role']?.toString().toLowerCase().trim() ?? 
                data['user']?['role']?.toString().toLowerCase().trim() ?? 
                'user';
        
        final userMap = data['user'];
        if (userMap != null) {
          if (userMap['balance'] != null) {
            _balance = double.parse(userMap['balance'].toString());
          }
          if (userMap['id'] != null) {
            _userId = int.parse(userMap['id'].toString());
          }
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token);
        await prefs.setString('role', _role);
        
        if (userMap == null) {
          await fetchProfile();
        }
        
        notifyListeners();
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  Future<void> logout() async {
    _token = '';
    _isAuthenticated = false;
    _role = 'user';
    _userId = 0;
    _balance = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    notifyListeners();
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _token = data['token'];
        _isAuthenticated = true;
        _role = data['user']['role']?.toString().toLowerCase().trim() ?? 'user';
        
        final userMap = data['user'];
        if (userMap != null && userMap['balance'] != null) {
          _balance = double.parse(userMap['balance'].toString());
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token);
        await prefs.setString('role', _role);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;
    _token = prefs.getString('token') ?? '';
    _role = prefs.getString('role') ?? 'user';
    _isAuthenticated = true;
    notifyListeners();
    // Fetch fresh profile details/balance asynchronously
    fetchProfile();
  }

  void updateBalance(double val) {
    _balance = val;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    if (_token.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['user'] != null) {
        final userMap = data['user'];
        _role = userMap['role']?.toString().toLowerCase().trim() ?? 'user';
        if (userMap['balance'] != null) {
          _balance = double.parse(userMap['balance'].toString());
        }
        if (userMap['id'] != null) {
          _userId = int.parse(userMap['id'].toString());
        }
        notifyListeners();
      }
    } catch (_) {
      // Return silently on connection issue
    }
  }
}
