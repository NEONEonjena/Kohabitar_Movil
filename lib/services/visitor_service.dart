/// Servicio de Visitantes
/// 
/// Este servicio maneja todas las operaciones relacionadas con los visitantes
/// en la aplicación. Proporciona métodos para obtener, crear, actualizar y
/// eliminar registros de visitantes a través de la API.
/// 
/// Capa en la arquitectura: Services (Servicios)
/// - Depende de: ApiClient
/// - Utilizado por: VisitorRepository
library;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/visitor.dart';

// Se utiliza ApiResponse desde api_client.dart

class VisitorService {
  final ApiClient _apiClient;
  
  /// Constructor del servicio
  /// 
  /// Permite inyección de dependencias para facilitar pruebas unitarias
  /// 
  /// @param apiClient Cliente API a utilizar (opcional, usa el singleton por defecto)
  VisitorService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  /// Obtiene todos los visitantes
  /// 
  /// Endpoint: GET /visitors
  /// 
  /// @return ApiResponse con lista de objetos Visitor o mensaje de error
  Future<ApiResponse<List<Visitor>>> getVisitors() async {
    return _apiClient.get<List<Visitor>>(
      ApiConstants.visitors,
      (json) {
        List<Visitor> visitors = [];
        if (json['data'] != null && json['data'] is List) {
          visitors = (json['data'] as List).map((item) => Visitor.fromJson(item)).toList();
        }
        return visitors;
      },
    );
  }
  
  /// Obtiene un visitante por su ID
  /// 
  /// Endpoint: GET /visitors/:id
  /// 
  /// @param id Identificador único del visitante
  /// @return ApiResponse con objeto Visitor o mensaje de error
  Future<ApiResponse<Visitor>> getVisitorById(int id) async {
    return _apiClient.get<Visitor>(
      '${ApiConstants.visitors}/$id',
      (json) => Visitor.fromJson(json['data'] ?? {}),
    );
  }
  
  /// Crea un nuevo visitante
  /// 
  /// Endpoint: POST /visitors
  /// 
  /// @param visitorData Mapa con los datos del nuevo visitante
  /// @return ApiResponse con objeto Visitor creado o mensaje de error
  Future<ApiResponse<Visitor>> createVisitor(Map<String, dynamic> visitorData) async {
    return _apiClient.post<Visitor>(
      ApiConstants.visitors,
      (json) => Visitor.fromJson(json['data'] ?? {}),
      body: visitorData,
    );
  }
  
  /// Actualiza un visitante existente
  /// 
  /// Endpoint: PUT /visitors/:id
  /// 
  /// @param id Identificador único del visitante a actualizar
  /// @param visitorData Mapa con los datos actualizados
  /// @return ApiResponse con objeto Visitor actualizado o mensaje de error
  Future<ApiResponse<Visitor>> updateVisitor(int id, Map<String, dynamic> visitorData) async {
    return _apiClient.put<Visitor>(
      '${ApiConstants.visitors}/$id',
      (json) => Visitor.fromJson(json['data'] ?? {}),
      body: visitorData,
    );
  }
  
  /// Elimina un visitante
  /// 
  /// Endpoint: DELETE /visitors/:id
  /// 
  /// @param id Identificador único del visitante a eliminar
  /// @return ApiResponse con booleano indicando éxito o mensaje de error
  Future<ApiResponse<bool>> deleteVisitor(int id) async {
    return _apiClient.delete<bool>(
      '${ApiConstants.visitors}/$id',
      (json) => json['success'] ?? false,
    );
  }
}