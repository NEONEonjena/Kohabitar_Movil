/// Proveedor de Autenticación
/// 
/// Esta clase gestiona el estado de autenticación del usuario en la aplicación
/// y notifica a los widgets cuando hay cambios en este estado.
library;

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class AuthProvider extends ChangeNotifier {
  // El servicio de autenticación que gestiona las peticiones al servidor
  final AuthService _authService;
  
  // El usuario actualmente autenticado (null si no hay sesión)
  User? _user;
  
  // Indica si existe un usuario con sesión iniciada
  bool _isLoggedIn = false;
  
  // Indica si se está procesando una petición al servidor
  bool _isLoading = true;
  
  // Mensaje de error (si existe alguno)
  String? _errorMessage;
  
  // Getters públicos que permiten acceder al estado actual
  User? get user => _user;
  String? get username => _user?.username;
  String? get name => _user?.name;
  String? get lastName => _user?.lastName;
  String? get email => _user?.email;
  String? get role => _user?.role;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor del proveedor de autenticación
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Al crear el proveedor, se intenta cargar la sesión previamente guardada
    _loadSavedSession();
  }

  // Carga la sesión guardada al iniciar la aplicación
  Future<void> _loadSavedSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();  // Se notifica a los widgets que el estado ha cambiado

    try {
      // Se verifica si existe una sesión guardada
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        // Si existe una sesión, se cargan los datos del usuario
        _user = await _authService.getCurrentUser();
        _isLoggedIn = _user != null;
      } else {
        // Si no existe sesión, se limpia el estado
        _isLoggedIn = false;
        _user = null;
      }
      
      debugPrint('AuthProvider - Loaded session: $_isLoggedIn, ${_user?.username}');
    } catch (e) {
      // Si ocurre un error, se guarda y se limpia el estado
      debugPrint('Error loading session: $e');
      _errorMessage = 'Error al cargar la sesión';
      _isLoggedIn = false;
      _user = null;
    } finally {
      // Al finalizar, se actualiza el estado de carga y se notifica
      _isLoading = false;
      notifyListeners();
    }
  }

  // Realiza el inicio de sesión con nombre de usuario y contraseña
  Future<bool> login(String username, String password) async {
    // Se actualiza el estado a "cargando" y se notifica
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Se intenta iniciar sesión utilizando el servicio
      _user = await _authService.login(username, password);
      
      // Si se llega hasta aquí, el inicio de sesión fue exitoso
      _isLoggedIn = true;
      
      debugPrint('AuthProvider - Login successful: ${_user?.username}');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Si se produce un error, se registra y se limpia el estado
      debugPrint('Error during login: $e');
      _errorMessage = 'Usuario o contraseña incorrectos';
      _isLoggedIn = false;
      _user = null;
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cierra la sesión activa del usuario
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Se cierra la sesión utilizando el servicio
      await _authService.logout();
      
      // Se limpia el estado actual
      _user = null;
      _isLoggedIn = false;
      
      debugPrint('AuthProvider - Logout successful');
    } catch (e) {
      // Si se produce un error, se registra
      debugPrint('Error during logout: $e');
      _errorMessage = 'Error al cerrar sesión';
    } finally {
      // Al finalizar, se actualiza el estado de carga y se notifica
      _isLoading = false;
      notifyListeners();
    }
  }
}