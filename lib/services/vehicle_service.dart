/// Servicio de Vehículos
/// 
/// Este servicio maneja todas las operaciones relacionadas con los vehículos
/// en la aplicación. Se comunica con la API para realizar operaciones CRUD.
/// 
/// Capa en la arquitectura: Services (Servicios)
/// - Depende de: ApiClient
/// - Utilizado por: VehicleRepository
library;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/vehicle.dart';

class VehicleService {
  /// Implementación del patrón Singleton para asegurar una única instancia
  /// del servicio en toda la aplicación.
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  
  final ApiClient _apiClient;
  
  /// Constructor privado que inicializa el cliente API
  VehicleService._internal() : _apiClient = ApiClient();
  
  /// Obtiene todos los vehículos
  /// 
  /// Endpoint: GET /vehicle
  /// 
  /// @return ApiResponse con lista de objetos Vehicle o mensaje de error
  Future<ApiResponse<List<Vehicle>>> getVehicles() async {
    return _apiClient.get<List<Vehicle>>(
      '${ApiConstants.apiVersion}/vehicle',
      (json) {
        List<Vehicle> vehicles = [];
        if (json['data'] != null && json['data'] is List) {
          vehicles = (json['data'] as List).map((item) => Vehicle.fromJson(item)).toList();
        }
        return vehicles;
      },
    );
  }
  
  /// Obtiene los vehículos por ID de propiedad
  /// 
  /// Endpoint: GET /vehicle/property/:propertyId
  /// 
  /// @param propertyId Identificador único de la propiedad
  /// @return ApiResponse con lista filtrada de objetos Vehicle o mensaje de error
  Future<ApiResponse<List<Vehicle>>> getVehiclesByProperty(int propertyId) async {
    return _apiClient.get<List<Vehicle>>(
      '${ApiConstants.apiVersion}/vehicle/property/$propertyId',
      (json) {
        List<Vehicle> vehicles = [];
        if (json['data'] != null && json['data'] is List) {
          vehicles = (json['data'] as List).map((item) => Vehicle.fromJson(item)).toList();
        }
        return vehicles;
      },
    );
  }
  
  /// Registra un nuevo vehículo
  /// 
  /// Endpoint: POST /vehicle
  /// 
  /// @param vehicleData Mapa con los datos del vehículo a registrar
  /// @return ApiResponse con objeto Vehicle creado o mensaje de error
  Future<ApiResponse<Vehicle>> createVehicle(Map<String, dynamic> vehicleData) async {
    return _apiClient.post<Vehicle>(
      '${ApiConstants.apiVersion}/vehicle',
      (json) => Vehicle.fromJson(json['data'] ?? {}),
      body: vehicleData,
    );
  }
  
  /// Asigna un vehículo a un espacio de parqueadero
  /// 
  /// Endpoint: PUT /vehicle/:id
  /// 
  /// @param vehicleId Identificador del vehículo
  /// @param updateData Mapa con los datos actualizados incluyendo el código de parqueadero
  /// @return ApiResponse con objeto Vehicle actualizado o mensaje de error
  Future<ApiResponse<Vehicle>> assignVehicleToParkingSlot(String vehicleId, Map<String, dynamic> updateData) async {
    return _apiClient.put<Vehicle>(
      '${ApiConstants.apiVersion}/vehicle/$vehicleId',
      (json) => Vehicle.fromJson(json['data'] ?? {}),
      body: updateData,
    );
  }
  
  /// Elimina un vehículo
  /// 
  /// Endpoint: DELETE /vehicle/:id
  /// 
  /// @param vehicleId Identificador del vehículo a eliminar
  /// @return ApiResponse con booleano indicando éxito o mensaje de error
  Future<ApiResponse<bool>> deleteVehicle(String vehicleId) async {
    return _apiClient.delete<bool>(
      '${ApiConstants.apiVersion}/vehicle/$vehicleId',
      (json) => json['success'] ?? false,
    );
  }

  /// Obtiene un vehículo por su ID
  /// 
  /// Endpoint: GET /vehicle/:id
  /// 
  /// @param id Identificador único del vehículo
  /// @return ApiResponse con objeto Vehicle o mensaje de error
  Future<ApiResponse<Vehicle>> getVehicleById(String id) async {
    return _apiClient.get<Vehicle>(
      '${ApiConstants.apiVersion}/vehicle/$id',
      (json) => Vehicle.fromJson(json['data'] ?? {}),
    );
  }

  /// Obtiene los vehículos por tipo
  /// 
  /// Endpoint: GET /vehicle/type/:type
  /// 
  /// @param type Tipo de vehículo
  /// @return ApiResponse con lista de objetos Vehicle o mensaje de error
  Future<ApiResponse<List<Vehicle>>> getVehiclesByType(String type) async {
    return _apiClient.get<List<Vehicle>>(
      '${ApiConstants.apiVersion}/vehicle/type/$type',
      (json) {
        List<Vehicle> vehicles = [];
        if (json['data'] != null && json['data'] is List) {
          vehicles = (json['data'] as List).map((item) => Vehicle.fromJson(item)).toList();
        }
        return vehicles;
      },
    );
  }
  
  /// Obtiene los vehículos por usuario
  /// 
  /// Endpoint: GET /vehicle/user/:userId
  /// 
  /// @param userId Identificador único del usuario
  /// @return ApiResponse con lista de objetos Vehicle o mensaje de error
  Future<ApiResponse<List<Vehicle>>> getVehiclesByUser(int userId) async {
    return _apiClient.get<List<Vehicle>>(
      '${ApiConstants.apiVersion}/vehicle/user/$userId',
      (json) {
        List<Vehicle> vehicles = [];
        if (json['data'] != null && json['data'] is List) {
          vehicles = (json['data'] as List).map((item) => Vehicle.fromJson(item)).toList();
        }
        return vehicles;
      },
    );
  }
}