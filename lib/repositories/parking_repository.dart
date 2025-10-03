import '../models/parking.dart';
import '../services/parking_service.dart';

class ParkingRepository {
  final ParkingService _parkingService;
  
  ParkingRepository({ParkingService? parkingService}) 
      : _parkingService = parkingService ?? ParkingService();
  
  // Obtener todos los parqueaderos
  Future<List<Parking>> getAllParkings() async {
    try {
      final response = await _parkingService.getParkings();
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener parqueaderos');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar los parqueaderos: ${e.toString()}');
    }
  }
  
  // Obtener parqueadero por ID
  Future<Parking> getParkingById(int id) async {
    try {
      final response = await _parkingService.getParkingById(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener el parqueadero');
      }
    } catch (e) {
      throw Exception('No se pudo cargar el parqueadero: ${e.toString()}');
    }
  }
  
  // Crear parqueadero
  Future<Parking> createParking({
    required String name,
    String? description,
    String? location,
    int? propertyId,
  }) async {
    try {
      final parkingData = {
        'name': name,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (propertyId != null) 'property_id': propertyId,
      };
      
      final response = await _parkingService.createParking(parkingData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al crear el parqueadero');
      }
    } catch (e) {
      throw Exception('No se pudo crear el parqueadero: ${e.toString()}');
    }
  }
  
  // Actualizar parqueadero
  Future<Parking> updateParking(int id, {
    String? name,
    String? description,
    String? location,
    int? propertyId,
    String? status,
  }) async {
    try {
      final parkingData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (propertyId != null) 'property_id': propertyId,
        if (status != null) 'status_id': status,
      };
      
      final response = await _parkingService.updateParking(id, parkingData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar el parqueadero');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el parqueadero: ${e.toString()}');
    }
  }
  
  // Eliminar parqueadero
  Future<bool> deleteParking(int id) async {
    try {
      final response = await _parkingService.deleteParking(id);
      
      if (response.success && response.data != null) {
        return true;
      } else {
        throw Exception(response.message ?? 'Error al eliminar el parqueadero');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar el parqueadero: ${e.toString()}');
    }
  }
}