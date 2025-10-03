/**
 * Servicio de Usuarios
 * 
 * Este servicio maneja todas las operaciones relacionadas con los usuarios
 * en la aplicación. Proporciona métodos para obtener, crear, actualizar y
 * eliminar usuarios a través de la API.
 * 
 * Capa en la arquitectura: Services (Servicios)
 * - Depende de: ApiClient
 * - Utilizado por: UserRepository
 */
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/user.dart';

// Se utiliza ApiResponse desde api_client.dart

class UserService {
  final ApiClient _apiClient;
  
  /**
   * Constructor del servicio
   * 
   * Permite inyección de dependencias para facilitar pruebas unitarias
   * 
   * @param apiClient Cliente API a utilizar (opcional, usa el singleton por defecto)
   */
  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  /**
   * Obtiene todos los usuarios
   * 
   * Endpoint: GET /users
   * 
   * @return ApiResponse con lista de objetos User o mensaje de error
   */
  Future<ApiResponse<List<User>>> getUsers() async {
    return _apiClient.get<List<User>>(
      ApiConstants.users,
      (json) {
        List<User> users = [];
        if (json['data'] != null && json['data'] is List) {
          users = (json['data'] as List).map((item) => User.fromJson(item)).toList();
        }
        return users;
      },
    );
  }
  
  /**
   * Obtiene un usuario por su ID
   * 
   * Endpoint: GET /users/:id
   * 
   * @param id Identificador único del usuario
   * @return ApiResponse con objeto User o mensaje de error
   */
  Future<ApiResponse<User>> getUserById(int id) async {
    return _apiClient.get<User>(
      '${ApiConstants.users}/$id',
      (json) => User.fromJson(json['data'] ?? {}),
    );
  }
  
  /**
   * Crea un nuevo usuario
   * 
   * Endpoint: POST /users
   * 
   * @param userData Mapa con los datos del nuevo usuario
   * @return ApiResponse con objeto User creado o mensaje de error
   */
  Future<ApiResponse<User>> createUser(Map<String, dynamic> userData) async {
    return _apiClient.post<User>(
      ApiConstants.users,
      (json) => User.fromJson(json['data'] ?? {}),
      body: userData,
    );
  }
  
  /**
   * Actualiza un usuario existente
   * 
   * Endpoint: PUT /users/:id
   * 
   * @param id Identificador único del usuario a actualizar
   * @param userData Mapa con los datos actualizados
   * @return ApiResponse con objeto User actualizado o mensaje de error
   */
  Future<ApiResponse<User>> updateUser(int id, Map<String, dynamic> userData) async {
    return _apiClient.put<User>(
      '${ApiConstants.users}/$id',
      (json) => User.fromJson(json['data'] ?? {}),
      body: userData,
    );
  }
  
  /**
   * Elimina un usuario
   * 
   * Endpoint: DELETE /users/:id
   * 
   * @param id Identificador único del usuario a eliminar
   * @return ApiResponse con booleano indicando éxito o mensaje de error
   */
  Future<ApiResponse<bool>> deleteUser(int id) async {
    return _apiClient.delete<bool>(
      '${ApiConstants.users}/$id',
      (json) => json['success'] ?? false,
    );
  }
}