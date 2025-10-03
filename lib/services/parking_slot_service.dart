/// Servicio de Espacios de Parqueo (ParkingSlot Service)
/// 
/// Esta clase proporciona métodos para interactuar con los endpoints de la API
/// relacionados con los espacios de parqueo individuales dentro de las zonas.
/// 
/// El servicio utiliza el cliente API centralizado para realizar las peticiones
/// HTTP y procesar las respuestas.
library;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/parking_slot.dart';

// Usamos ApiResponse directamente de api_client.dart

class ParkingSlotService {
  final ApiClient _apiClient;
  
  // Constructor del servicio
  ParkingSlotService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  // Obtiene todos los espacios de parqueo
  Future<ApiResponse<List<ParkingSlot>>> getParkingSlots() async {
    print('Llamando a API: ${ApiConstants.parkingSlots}');
    try {
      final response = await _apiClient.get<List<ParkingSlot>>(
        ApiConstants.parkingSlots,
        (json) {
          List<ParkingSlot> slots = [];
          if (json['data'] != null && json['data'] is List) {
            print('Datos recibidos: ${json['data'].length} slots');
            slots = (json['data'] as List).map((item) => ParkingSlot.fromJson(item)).toList();
          } else {
            print('No se recibieron datos de slots o formato incorrecto: ${json['data']}');
          }
          return slots;
        },
      );
      print('Respuesta API: ${response.success}, slots: ${response.data?.length}, mensaje: ${response.message}');
      return response;
    } catch (e) {
      print('Error en getParkingSlots: $e');
      rethrow;
    }
  }
  
  // Obtiene los espacios disponibles (no reservados)
  Future<ApiResponse<List<ParkingSlot>>> getAvailableSlots() async {
    return _apiClient.get<List<ParkingSlot>>(
      '${ApiConstants.parkingSlots}/available',
      (json) {
        List<ParkingSlot> slots = [];
        if (json['data'] != null && json['data'] is List) {
          slots = (json['data'] as List).map((item) => ParkingSlot.fromJson(item)).toList();
        }
        return slots;
      },
    );
  }
  
  // Obtiene los espacios reservados
  Future<ApiResponse<List<ParkingSlot>>> getReservedSlots() async {
    return _apiClient.get<List<ParkingSlot>>(
      '${ApiConstants.parkingSlots}/reserved',
      (json) {
        List<ParkingSlot> slots = [];
        if (json['data'] != null && json['data'] is List) {
          slots = (json['data'] as List).map((item) => ParkingSlot.fromJson(item)).toList();
        }
        return slots;
      },
    );
  }
  
  // Obtiene los espacios de una zona específica
  Future<ApiResponse<List<ParkingSlot>>> getSlotsByZone(int zoneId) async {
    print('Llamando a API: ${ApiConstants.parkingSlots}/zone/$zoneId');
    try {
      final response = await _apiClient.get<List<ParkingSlot>>(
        '${ApiConstants.parkingSlots}/zone/$zoneId',
        (json) {
          List<ParkingSlot> slots = [];
          if (json['data'] != null && json['data'] is List) {
            print('Datos recibidos para zona $zoneId: ${json['data'].length} slots');
            slots = (json['data'] as List).map((item) => ParkingSlot.fromJson(item)).toList();
          } else {
            print('No se recibieron datos de slots para zona $zoneId o formato incorrecto: ${json['data']}');
          }
          return slots;
        },
      );
      print('Respuesta API zona $zoneId: ${response.success}, slots: ${response.data?.length}, mensaje: ${response.message}');
      return response;
    } catch (e) {
      print('Error en getSlotsByZone: $e');
      rethrow;
    }
  }
  
  // Obtiene un espacio de parqueo por su ID
  Future<ApiResponse<ParkingSlot>> getParkingSlotById(int id) async {
    return _apiClient.get<ParkingSlot>(
      '${ApiConstants.parkingSlots}/$id',
      (json) => ParkingSlot.fromJson(json['data'] ?? {}),
    );
  }
  
  // Crea un nuevo espacio de parqueo
  Future<ApiResponse<ParkingSlot>> createParkingSlot(Map<String, dynamic> slotData) async {
    return _apiClient.post<ParkingSlot>(
      ApiConstants.parkingSlots,
      (json) => ParkingSlot.fromJson(json['data'] ?? {}),
      body: slotData,
    );
  }
  
  // Actualiza un espacio de parqueo existente
  Future<ApiResponse<ParkingSlot>> updateParkingSlot(int id, Map<String, dynamic> slotData) async {
    return _apiClient.put<ParkingSlot>(
      '${ApiConstants.parkingSlots}/$id',
      (json) => ParkingSlot.fromJson(json['data'] ?? {}),
      body: slotData,
    );
  }
  
  // Elimina un espacio de parqueo
  Future<ApiResponse<bool>> deleteParkingSlot(int id) async {
    return _apiClient.delete<bool>(
      '${ApiConstants.parkingSlots}/$id',
      (json) => json['success'] ?? false,
    );
  }
}