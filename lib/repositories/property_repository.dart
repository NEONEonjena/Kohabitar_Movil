import '../models/property.dart';
import '../services/property_service.dart';

class PropertyRepository {
  final PropertyService _propertyService;
  
  PropertyRepository({PropertyService? propertyService}) 
      : _propertyService = propertyService ?? PropertyService();
  
  // Obtener todas las propiedades
  Future<List<Property>> getAllProperties() async {
    try {
      final response = await _propertyService.getProperties();
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener propiedades');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar las propiedades: ${e.toString()}');
    }
  }
  
  // Obtener propiedad por ID
  Future<Property> getPropertyById(int id) async {
    try {
      final response = await _propertyService.getPropertyById(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener la propiedad');
      }
    } catch (e) {
      throw Exception('No se pudo cargar la propiedad: ${e.toString()}');
    }
  }
  
  // Crear propiedad
  Future<Property> createProperty({
    required String name,
    String? description,
    String? location,
    int? ownerId,
    String? type,
  }) async {
    try {
      final propertyData = {
        'name': name,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (ownerId != null) 'owner_id': ownerId,
        if (type != null) 'type_id': type,
      };
      
      final response = await _propertyService.createProperty(propertyData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al crear la propiedad');
      }
    } catch (e) {
      throw Exception('No se pudo crear la propiedad: ${e.toString()}');
    }
  }
  
  // Actualizar propiedad
  Future<Property> updateProperty(int id, {
    String? name,
    String? description,
    String? location,
    int? ownerId,
    String? type,
    String? status,
  }) async {
    try {
      final propertyData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (ownerId != null) 'owner_id': ownerId,
        if (type != null) 'type_id': type,
        if (status != null) 'status_id': status,
      };
      
      final response = await _propertyService.updateProperty(id, propertyData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar la propiedad');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar la propiedad: ${e.toString()}');
    }
  }
  
  // Eliminar propiedad
  Future<bool> deleteProperty(int id) async {
    try {
      final response = await _propertyService.deleteProperty(id);
      
      if (response.success && response.data != null) {
        return true;
      } else {
        throw Exception(response.message ?? 'Error al eliminar la propiedad');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar la propiedad: ${e.toString()}');
    }
  }
}