/**
 * Servicio de Propiedades
 * 
 * Este servicio maneja todas las operaciones relacionadas con las propiedades
 * en la aplicación. Proporciona métodos para obtener, crear, actualizar y
 * eliminar propiedades a través de la API.
 * 
 * Capa en la arquitectura: Services (Servicios)
 * - Depende de: ApiClient
 * - Utilizado por: PropertyRepository
 */
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/property.dart';

class PropertyService {
  final ApiClient _apiClient;
  
  /**
   * Constructor del servicio
   * 
   * Permite inyección de dependencias para facilitar pruebas unitarias
   * 
   * @param apiClient Cliente API a utilizar (opcional, usa el singleton por defecto)
   */
  PropertyService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  /**
   * Obtiene todas las propiedades
   * 
   * Endpoint: GET /properties
   * 
   * @return ApiResponse con lista de objetos Property o mensaje de error
   */
  Future<ApiResponse<List<Property>>> getProperties() async {
    return _apiClient.get<List<Property>>(
      ApiConstants.properties,
      (json) {
        List<Property> properties = [];
        if (json['data'] != null && json['data'] is List) {
          properties = (json['data'] as List).map((item) => Property.fromJson(item)).toList();
        }
        return properties;
      },
    );
  }
  
  /**
   * Obtiene una propiedad por su ID
   * 
   * Endpoint: GET /properties/:id
   * 
   * @param id Identificador único de la propiedad
   * @return ApiResponse con objeto Property o mensaje de error
   */
  Future<ApiResponse<Property>> getPropertyById(int id) async {
    return _apiClient.get<Property>(
      '${ApiConstants.properties}/$id',
      (json) => Property.fromJson(json['data'] ?? {}),
    );
  }

  /**
   * Obtiene propiedades por tipo
   * 
   * Endpoint: GET /properties/type/:type
   * 
   * @param type Tipo de propiedad a filtrar
   * @return ApiResponse con lista de objetos Property o mensaje de error
   */
  Future<ApiResponse<List<Property>>> getPropertiesByType(String type) async {
    return _apiClient.get<List<Property>>(
      '${ApiConstants.properties}/type/$type',
      (json) {
        List<Property> properties = [];
        if (json['data'] != null && json['data'] is List) {
          properties = (json['data'] as List).map((item) => Property.fromJson(item)).toList();
        }
        return properties;
      },
    );
  }

  /**
   * Busca una propiedad por nombre
   * 
   * Endpoint: GET /properties/search?name=:name
   * 
   * @param name Nombre de la propiedad a buscar
   * @return ApiResponse con objeto Property o mensaje de error
   */
  Future<ApiResponse<Property>> searchPropertyByName(String name) async {
    return _apiClient.get<Property>(
      '${ApiConstants.properties}/search?name=$name',
      (json) => Property.fromJson(json['data'] ?? {}),
    );
  }
  
  /**
   * Crea una nueva propiedad
   * 
   * Endpoint: POST /properties
   * 
   * @param propertyData Mapa con los datos de la nueva propiedad
   * @return ApiResponse con objeto Property creado o mensaje de error
   */
  Future<ApiResponse<Property>> createProperty(Map<String, dynamic> propertyData) async {
    return _apiClient.post<Property>(
      ApiConstants.properties,
      (json) => Property.fromJson(json['data'] ?? {}),
      body: propertyData,
    );
  }
  
  /**
   * Actualiza una propiedad existente
   * 
   * Endpoint: PUT /properties/:id
   * 
   * @param id Identificador único de la propiedad a actualizar
   * @param propertyData Mapa con los datos actualizados
   * @return ApiResponse con objeto Property actualizado o mensaje de error
   */
  Future<ApiResponse<Property>> updateProperty(int id, Map<String, dynamic> propertyData) async {
    return _apiClient.put<Property>(
      '${ApiConstants.properties}/$id',
      (json) => Property.fromJson(json['data'] ?? {}),
      body: propertyData,
    );
  }
  
  /**
   * Elimina una propiedad
   * 
   * Endpoint: DELETE /properties/:id
   * 
   * @param id Identificador único de la propiedad a eliminar
   * @return ApiResponse con booleano indicando éxito o mensaje de error
   */
  Future<ApiResponse<bool>> deleteProperty(int id) async {
    return _apiClient.delete<bool>(
      '${ApiConstants.properties}/$id',
      (json) => json['success'] ?? false,
    );
  }
}