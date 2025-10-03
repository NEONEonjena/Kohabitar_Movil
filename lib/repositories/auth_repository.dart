import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  
  AuthRepository({AuthService? authService}) 
      : _authService = authService ?? AuthService();
  
  // Iniciar sesión
  Future<app_user.User> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      
      if (response.success && response.data != null) {
        // Guardar el token en SharedPreferences
        await _saveAuthData(response.data!.token, response.data!.user);
        
        // Convertir el modelo User de AuthResponse al modelo User de la app
        return app_user.User(
          id: response.data!.user.id,
          username: response.data!.user.username,
          email: response.data!.user.email,
          name: response.data!.user.name,
          lastName: response.data!.user.lastName,
          role: response.data!.user.role,
        );
      } else {
        throw Exception(response.message ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      throw Exception('No se pudo iniciar sesión: ${e.toString()}');
    }
  }
  
  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Verificar validez del token con el servidor
      final response = await _authService.verifyToken(token);
      return response.success && response.data != null && response.data!;
    } catch (e) {
      print('Error al verificar autenticación: $e');
      return false;
    }
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('name');
      await prefs.remove('lastName');
      await prefs.remove('role');
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }
  
  // Guardar datos de autenticación
  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setInt('userId', user.id);
      await prefs.setString('username', user.username);
      
      if (user.email != null) {
        await prefs.setString('email', user.email!);
      }
      
      if (user.name != null) {
        await prefs.setString('name', user.name!);
      }
      
      if (user.lastName != null) {
        await prefs.setString('lastName', user.lastName!);
      }
      
      if (user.role != null) {
        await prefs.setString('role', user.role!);
      }
    } catch (e) {
      throw Exception('Error al guardar datos de autenticación: ${e.toString()}');
    }
  }
  
  // Obtener usuario actual desde SharedPreferences
  Future<app_user.User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');
      
      if (userId == null || username == null) {
        return null;
      }
      
      return app_user.User(
        id: userId,
        username: username,
        email: prefs.getString('email'),
        name: prefs.getString('name'),
        lastName: prefs.getString('lastName'),
        role: prefs.getString('role'),
      );
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }
}