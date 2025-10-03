/// Repositorio de Espacios de Parqueo (ParkingSlot Repository)
/// 
/// Esta clase sirve como intermediaria entre las capas de UI y servicios.
/// Proporciona métodos para acceder a los datos de espacios de parqueo
/// y maneja la lógica de negocio relacionada con estos datos.
library;
import '../models/parking_slot.dart';
import '../services/parking_slot_service.dart';

class ParkingSlotRepository {
  final ParkingSlotService _parkingSlotService;
  
  ParkingSlotRepository({ParkingSlotService? parkingSlotService})
      : _parkingSlotService = parkingSlotService ?? ParkingSlotService();
  
  // Obtiene todos los espacios de parqueo
  Future<List<ParkingSlot>> getAllParkingSlots() async {
    try {
      final response = await _parkingSlotService.getParkingSlots();
      print('Repositorio - getAllParkingSlots: ${response.success}, datos: ${response.data?.length}');
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Error al obtener espacios de parqueo';
        print('Repositorio - error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'No se pudieron cargar los espacios de parqueo: ${e.toString()}';
      print('Repositorio - excepción: $errorMsg');
      throw Exception(errorMsg);
    }
  }
  
  // Obtiene los espacios disponibles (no reservados)
  Future<List<ParkingSlot>> getAvailableSlots() async {
    try {
      final response = await _parkingSlotService.getAvailableSlots();
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener espacios disponibles');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar los espacios disponibles: ${e.toString()}');
    }
  }
  
  // Obtiene los espacios reservados
  Future<List<ParkingSlot>> getReservedSlots() async {
    try {
      final response = await _parkingSlotService.getReservedSlots();
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener espacios reservados');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar los espacios reservados: ${e.toString()}');
    }
  }
  
  // Obtiene los espacios de una zona específica
  Future<List<ParkingSlot>> getSlotsByZone(int zoneId) async {
    try {
      print('Repositorio - getSlotsByZone: buscando slots para zona $zoneId');
      final response = await _parkingSlotService.getSlotsByZone(zoneId);
      print('Repositorio - getSlotsByZone: ${response.success}, datos: ${response.data?.length}');
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Error al obtener espacios de la zona';
        print('Repositorio - getSlotsByZone error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'No se pudieron cargar los espacios de la zona: ${e.toString()}';
      print('Repositorio - getSlotsByZone excepción: $errorMsg');
      throw Exception(errorMsg);
    }
  }
  
  // Obtiene un espacio de parqueo por su ID
  Future<ParkingSlot> getParkingSlotById(int id) async {
    try {
      final response = await _parkingSlotService.getParkingSlotById(id);
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener el espacio de parqueo');
      }
    } catch (e) {
      throw Exception('No se pudo cargar el espacio de parqueo: ${e.toString()}');
    }
  }
  
  // Crea un nuevo espacio de parqueo
  Future<ParkingSlot> createParkingSlot(ParkingSlot parkingSlot) async {
    try {
      final response = await _parkingSlotService.createParkingSlot(parkingSlot.toJson());
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al crear el espacio de parqueo');
      }
    } catch (e) {
      throw Exception('No se pudo crear el espacio de parqueo: ${e.toString()}');
    }
  }
  
  // Actualiza un espacio de parqueo existente
  Future<ParkingSlot> updateParkingSlot(ParkingSlot parkingSlot) async {
    try {
      final response = await _parkingSlotService.updateParkingSlot(parkingSlot.id, parkingSlot.toJson());
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar el espacio de parqueo');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el espacio de parqueo: ${e.toString()}');
    }
  }
  
  // Elimina un espacio de parqueo
  Future<bool> deleteParkingSlot(int id) async {
    try {
      final response = await _parkingSlotService.deleteParkingSlot(id);
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al eliminar el espacio de parqueo');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar el espacio de parqueo: ${e.toString()}');
    }
  }
}