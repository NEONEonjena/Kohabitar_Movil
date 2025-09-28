import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  String? _password;
  bool _isLoggedIn = false;
  bool _isLoading = true; // Agregar estado de carga

  String? get username => _username;
  String? get password => _password;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading; // Getter para el estado de carga

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _username = prefs.getString('username');
      _password = prefs.getString('password');

      print('AuthProvider - Loaded session: $_isLoggedIn, $_username'); // Debug

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading session: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    try {
      _username = username;
      _password = password;
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('password', password);

      print('AuthProvider - Login successful: $_username'); // Debug

      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
    }
  }

  Future<void> logout() async {
    try {
      _username = null;
      _password = null;
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('AuthProvider - Logout successful'); // Debug

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
