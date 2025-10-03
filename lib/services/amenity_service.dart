/**
 * Servicio de Zonas Comunes (Amenity Service)
 * 
 * Esta clase proporciona métodos para interactuar con los endpoints de la API
 * relacionados con las zonas comunes (amenities) del conjunto residencial.
 * 
 * El servicio utiliza el cliente API centralizado para realizar las peticiones
 * HTTP y procesar las respuestas.
 * 
 * Capa en la arquitectura: Services (Servicios)
 * - Depende de: ApiClient
 * - Utilizada por: AmenityRepository
 */
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/amenity.dart';

class AmenityService {
  final ApiClient _apiClient;
  
  /**
   * Constructor del servicio
   * 
   * Permite inyección de dependencias para facilitar pruebas unitarias
   * 
   * @param apiClient Cliente API a utilizar (opcional, usa el singleton por defecto)
   */
  AmenityService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  /**
   * Obtiene todas las zonas comunes
   * 
   * Endpoint: GET /amenities
   * 
   * @return ApiResponse con lista de objetos Amenity o mensaje de error
   */
  Future<ApiResponse<List<Amenity>>> getAmenities() async {
    return _apiClient.get<List<Amenity>>(
      ApiConstants.amenities,
      (json) {
        List<Amenity> amenities = [];
        // Procesar el arreglo de zonas comunes si existe
        if (json['data'] != null && json['data'] is List) {
          amenities = (json['data'] as List).map((item) => Amenity.fromJson(item)).toList();
        }
        return amenities;
      },
    );
  }
  
  /**
   * Obtiene una zona común por su ID
   * 
   * Endpoint: GET /amenities/:id
   * 
   * @param id Identificador único de la zona común
   * @return ApiResponse con objeto Amenity o mensaje de error
   */
  Future<ApiResponse<Amenity>> getAmenityById(int id) async {
    return _apiClient.get<Amenity>(
      '${ApiConstants.amenities}/$id',
      (json) => Amenity.fromJson(json['data'] ?? {}),
    );
  }
  
  /**
   * Crea una nueva zona común
   * 
   * Endpoint: POST /amenities
   * 
   * @param amenityData Mapa con los datos de la nueva zona común
   * @return ApiResponse con objeto Amenity creado o mensaje de error
   */
  Future<ApiResponse<Amenity>> createAmenity(Map<String, dynamic> amenityData) async {
    return _apiClient.post<Amenity>(
      ApiConstants.amenities,
      (json) => Amenity.fromJson(json['data'] ?? {}),
      body: amenityData,
    );
  }
  
  /**
   * Actualiza una zona común existente
   * 
   * Endpoint: PUT /amenities/:id
   * 
   * @param id Identificador único de la zona común a actualizar
   * @param amenityData Mapa con los datos actualizados
   * @return ApiResponse con objeto Amenity actualizado o mensaje de error
   */
  Future<ApiResponse<Amenity>> updateAmenity(int id, Map<String, dynamic> amenityData) async {
    return _apiClient.put<Amenity>(
      '${ApiConstants.amenities}/$id',
      (json) => Amenity.fromJson(json['data'] ?? {}),
      body: amenityData,
    );
  }
  
  /**
   * Elimina una zona común
   * 
   * Endpoint: DELETE /amenities/:id
   * 
   * @param id Identificador único de la zona común a eliminar
   * @return ApiResponse con booleano indicando éxito o mensaje de error
   */
  Future<ApiResponse<bool>> deleteAmenity(int id) async {
    return _apiClient.delete<bool>(
      '${ApiConstants.amenities}/$id',
      (json) => json['success'] ?? false,
    );
  }
}