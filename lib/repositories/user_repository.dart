import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _userService;
  
  UserRepository({UserService? userService}) 
      : _userService = userService ?? UserService();
  
  // Obtener todos los usuarios
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _userService.getUsers();
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener usuarios');
      }
    } catch (e) {
      // Re-lanzar errores con mensajes más amigables
      throw Exception('No se pudieron cargar los usuarios: ${e.toString()}');
    }
  }
  
  // Obtener usuario por ID
  Future<User> getUserById(int id) async {
    try {
      final response = await _userService.getUserById(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener el usuario');
      }
    } catch (e) {
      throw Exception('No se pudo cargar el usuario: ${e.toString()}');
    }
  }
  
  // Crear usuario
  Future<User> createUser({
    required String username,
    required String email,
    required String password,
    String? name,
    String? lastName,
  }) async {
    try {
      final userData = {
        'username': username,
        'email': email,
        'password': password,
        if (name != null) 'name': name,
        if (lastName != null) 'last_name': lastName,
      };
      
      final response = await _userService.createUser(userData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al crear el usuario');
      }
    } catch (e) {
      throw Exception('No se pudo crear el usuario: ${e.toString()}');
    }
  }
  
  // Actualizar usuario
  Future<User> updateUser(int id, {
    String? username,
    String? email,
    String? password,
    String? name,
    String? lastName,
  }) async {
    try {
      final userData = {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (name != null) 'name': name,
        if (lastName != null) 'last_name': lastName,
      };
      
      final response = await _userService.updateUser(id, userData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar el usuario');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el usuario: ${e.toString()}');
    }
  }
  
  // Eliminar usuario
  Future<bool> deleteUser(int id) async {
    try {
      final response = await _userService.deleteUser(id);
      
      if (response.success && response.data != null) {
        return true;
      } else {
        throw Exception(response.message ?? 'Error al eliminar el usuario');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar el usuario: ${e.toString()}');
    }
  }
}