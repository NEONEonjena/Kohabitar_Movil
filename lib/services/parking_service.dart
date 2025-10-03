import '../models/parking_slot.dart';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';

/**
 * Servicio de Parqueaderos (Parking Service)
 * 
 * Esta clase proporciona métodos para interactuar con los endpoints de la API
 * relacionados con los espacios de parqueo y zonas de parqueadero.
 * 
 * El servicio utiliza el cliente API centralizado para realizar las peticiones
 * HTTP y procesar las respuestas.
 */
class ParkingService {
  static final ParkingService _instance = ParkingService._internal();
  factory ParkingService() => _instance;
  
  final ApiClient _apiClient;
  
  ParkingService._internal() : _apiClient = ApiClient();
  
  // Constructor especial para pruebas unitarias
  ParkingService.test(this._apiClient);
  
  // Obtiene todos los espacios de parqueadero
  Future<List<ParkingSlot>> getAllParkingSlots() async {
    try {
      final response = await _apiClient.get<List<ParkingSlot>>(
        ApiConstants.parkingSlots,
        (json) {
          List<ParkingSlot> slots = [];
          if (json['data'] != null && json['data'] is List) {
            slots = (json['data'] as List).map((item) => ParkingSlot.fromJson(item)).toList();
          }
          return slots;
        },
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener los espacios de parqueadero');
      }
    } catch (e) {
      throw Exception('Error al obtener los espacios de parqueadero: $e');
    }
  }
  
  // Obtiene los espacios de parqueadero por propiedad
  Future<List<ParkingSlot>> getParkingSlotsByProperty(int propertyId) async {
    try {
      final response = await _apiClient.get<List<ParkingSlot>>(
        '${ApiConstants.properties}/$propertyId/parkingslots',
        (json) {
          List<ParkingSlot> slots = [];
          if (json['data'] != null && json['data'] is List) {
            slots = (json['data'] as List).map((item) => ParkingSlot.fromJson(item)).toList();
          }
          return slots;
        },
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener los espacios de parqueadero para la propiedad');
      }
    } catch (e) {
      throw Exception('Error al obtener los espacios de parqueadero de la propiedad: $e');
    }
  }
  
  // Asigna un vehículo a un espacio de parqueadero
  Future<ParkingSlot> assignVehicleToSlot(String slotId, String vehiclePlate) async {
    try {
      final response = await _apiClient.put<ParkingSlot>(
        '${ApiConstants.parkingSlots}/$slotId/assign',
        (json) => ParkingSlot.fromJson(json['data'] ?? {}),
        body: {'vehicle_license_plate': vehiclePlate},
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al asignar vehículo al espacio de parqueadero');
      }
    } catch (e) {
      throw Exception('Error al asignar vehículo al espacio de parqueadero: $e');
    }
  }
  
  // Libera un vehículo de un espacio de parqueadero
  Future<ParkingSlot> releaseVehicleFromSlot(String slotId) async {
    try {
      final response = await _apiClient.put<ParkingSlot>(
        '${ApiConstants.parkingSlots}/$slotId/release',
        (json) => ParkingSlot.fromJson(json['data'] ?? {}),
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al liberar vehículo del espacio de parqueadero');
      }
    } catch (e) {
      throw Exception('Error al liberar vehículo del espacio de parqueadero: $e');
    }
  }
  
  // Obtiene información de zonas de parqueadero
  Future<List<Map<String, dynamic>>> getParkingZones() async {
    try {
      final response = await _apiClient.get<List<Map<String, dynamic>>>(
        '${ApiConstants.parkings}/zones',
        (json) {
          List<Map<String, dynamic>> zones = [];
          if (json['data'] != null && json['data'] is List) {
            zones = (json['data'] as List).map((item) => item as Map<String, dynamic>).toList();
          }
          return zones;
        },
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener las zonas de parqueadero');
      }
    } catch (e) {
      throw Exception('Error al obtener las zonas de parqueadero: $e');
    }
  }
}