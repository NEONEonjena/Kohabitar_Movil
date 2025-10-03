/**
 * Servicio de Autenticación
 * 
 * Este servicio maneja todas las operaciones relacionadas con la autenticación de usuarios.
 * Proporciona métodos para iniciar sesión, cerrar sesión y verificar el estado de autenticación.
 * 
 * Capa en la arquitectura: Services (Servicios)
 * - Depende de: ApiClient
 * - Utilizado por: AuthRepository
 */

import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/user.dart';

class AuthService {
  // Cliente API para realizar peticiones al servidor
  final ApiClient _apiClient;
  
  /**
   * Constructor del servicio
   * 
   * Permite inyección de dependencias para facilitar pruebas unitarias
   * 
   * @param apiClient Cliente API a utilizar (opcional, usa el singleton por defecto)
   */
  AuthService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();
  
  /**
   * Realiza inicio de sesión con nombre de usuario y contraseña
   * 
   * Endpoint: POST /auth/login
   * 
   * @param username Nombre de usuario
   * @param password Contraseña del usuario
   * @return Usuario autenticado o null si falla la autenticación
   */
  Future<User?> login(String username, String password) async {
    try {
      // Realiza la petición de login al servidor
      final response = await _apiClient.post(
        ApiConstants.login,
        (json) => json['data'],
        body: {
          'username': username,
          'password': password,
        },
        requiresAuth: false,
      );
      
      // Verifica si la respuesta fue exitosa
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Extrae el token y los datos del usuario
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Guarda el token y los datos básicos del usuario
        await _saveUserSession(token, userData);
        
        // Crea y devuelve el objeto Usuario
        return User.fromJson(userData);
      } else {
        // Si hubo un error, lanza una excepción con el mensaje
        throw Exception(response.message ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      // Captura cualquier error y lo propaga
      print('Error en login: $e');
      throw Exception('No se pudo iniciar sesión: $e');
    }
  }

  /**
   * Verifica si el usuario se encuentra autenticado
   * 
   * @return true si el usuario está autenticado, false en caso contrario
   */
  Future<bool> isAuthenticated() async {
    try {
      // Obtiene el token guardado
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      // Si no hay token, no hay sesión
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Verifica el token con el servidor
      final response = await _apiClient.post(
        '${ApiConstants.apiVersion}/auth/verify-token',
        (json) => json['valid'] ?? false,
        requiresAuth: true,
      );
      
      return response.success && response.data == true;
    } catch (e) {
      print('Error al verificar autenticación: $e');
      return false;
    }
  }

  /**
   * Cierra la sesión activa del usuario
   */
  Future<void> logout() async {
    try {
      // Elimina todos los datos de sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('name');
      await prefs.remove('lastName');
      await prefs.remove('role');
      await prefs.remove('status');
      await prefs.remove('created_at');
      await prefs.remove('updated_at');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /**
   * Guarda los datos de la sesión en el almacenamiento local del dispositivo
   * 
   * @param token Token de autenticación
   * @param userData Datos del usuario
   */
  Future<void> _saveUserSession(String token, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guarda el token de autenticación
      await prefs.setString('authToken', token);
      
      // Guarda los datos básicos del usuario
      await prefs.setInt('userId', userData['user_id'] ?? 0);
      await prefs.setString('username', userData['username'] ?? '');
      
      // Guarda campos opcionales si existen
      if (userData['email'] != null) {
        await prefs.setString('email', userData['email']);
      }
      
      if (userData['name'] != null) {
        await prefs.setString('name', userData['name']);
      }
      
      if (userData['last_name'] != null) {
        await prefs.setString('lastName', userData['last_name']);
      }
      
      if (userData['role_name'] != null) {
        await prefs.setString('role', userData['role_name']);
      }

      if (userData['status_name'] != null) {
        await prefs.setString('status', userData['status_name']);
      }
      
      // Guardar fechas si existen
      if (userData['created_at'] != null) {
        await prefs.setString('created_at', userData['created_at']);
      }
      
      if (userData['updated_at'] != null) {
        await prefs.setString('updated_at', userData['updated_at']);
      }
    } catch (e) {
      print('Error al guardar sesión: $e');
      throw Exception('Error al guardar datos de sesión: $e');
    }
  }

  /**
   * Recupera la información del usuario actual desde el almacenamiento local
   * 
   * @return Usuario actual o null si no hay sesión activa
   */
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verifica si hay ID de usuario y nombre de usuario guardados
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');
      
      if (userId == null || username == null) {
        return null;
      }
      
      // Obtener fechas si existen
      DateTime? createdAt;
      DateTime? updatedAt;
      
      final createdAtStr = prefs.getString('created_at');
      if (createdAtStr != null) {
        try {
          createdAt = DateTime.parse(createdAtStr);
        } catch (e) {
          print('Error al parsear fecha de creación: $e');
        }
      }
      
      final updatedAtStr = prefs.getString('updated_at');
      if (updatedAtStr != null) {
        try {
          updatedAt = DateTime.parse(updatedAtStr);
        } catch (e) {
          print('Error al parsear fecha de actualización: $e');
        }
      }
      
      // Crea un objeto Usuario con los datos guardados
      return User(
        id: userId,
        username: username,
        email: prefs.getString('email'),
        name: prefs.getString('name'),
        lastName: prefs.getString('lastName'),
        role: prefs.getString('role'),
        status: prefs.getString('status'),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }

  /**
   * Valida la autenticidad del token actual con el servidor
   * 
   * @param token Token a verificar
   * @return ApiResponse con booleano indicando validez del token
   */
  Future<ApiResponse<bool>> verifyToken(String token) async {
    return _apiClient.post<bool>(
      '${ApiConstants.apiVersion}/auth/verify-token',
      (json) => json['success'] ?? false,
      requiresAuth: true,
    );
  }
}