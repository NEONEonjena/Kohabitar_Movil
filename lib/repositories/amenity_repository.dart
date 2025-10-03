/// Repositorio de Zonas Comunes (Amenity Repository)
/// 
/// Esta clase implementa la lógica de negocio relacionada con las zonas comunes
/// (amenidades) del conjunto residencial. Actúa como una capa de abstracción entre
/// los providers (UI) y los servicios que se comunican directamente con la API.
/// 
/// Responsabilidades:
/// - Proporcionar métodos con parámetros tipados (no solo mapas)
/// - Manejar excepciones y proporcionar mensajes de error claros
/// - Convertir respuestas de API en modelos de dominio
/// 
/// Capa en la arquitectura: Repositories (Repositorios)
/// - Depende de: AmenityService
/// - Utilizado por: Providers (AmenityProvider, ZonasComunesProvider, etc.)
library;
import '../models/amenity.dart';
import '../services/amenity_service.dart';

class AmenityRepository {
  final AmenityService _amenityService;
  
  /// Constructor del repositorio
  /// 
  /// Permite inyección de dependencias para facilitar pruebas unitarias
  /// 
  /// @param amenityService Servicio de zonas comunes a utilizar (opcional)
  AmenityRepository({AmenityService? amenityService}) 
      : _amenityService = amenityService ?? AmenityService();
  
  /// Obtiene todas las zonas comunes disponibles
  /// 
  /// @return Lista de objetos Amenity
  /// @throws Exception si ocurre un error al obtener los datos
  Future<List<Amenity>> getAllAmenities() async {
    try {
      final response = await _amenityService.getAmenities();
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener zonas comunes');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar las zonas comunes: ${e.toString()}');
    }
  }
  
  /// Obtiene una zona común por su identificador
  /// 
  /// @param id Identificador único de la zona común
  /// @return Objeto Amenity con los datos de la zona común
  /// @throws Exception si la zona común no existe o hay un error
  Future<Amenity> getAmenityById(int id) async {
    try {
      final response = await _amenityService.getAmenityById(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener la zona común');
      }
    } catch (e) {
      throw Exception('No se pudo cargar la zona común: ${e.toString()}');
    }
  }
  
  /// Crea una nueva zona común
  /// 
  /// @param name Nombre de la zona común (requerido)
  /// @param description Descripción de la zona común (opcional)
  /// @param capacity Capacidad máxima de personas (opcional)
  /// @return Objeto Amenity con los datos de la zona común creada
  /// @throws Exception si hay un error durante la creación
  Future<Amenity> createAmenity({
    required String name,
    String? description,
    double? capacity,
  }) async {
    try {
      // Preparar datos para enviar al servicio
      final amenityData = {
        'name': name,
        if (description != null) 'description': description,
        if (capacity != null) 'capacity': capacity,
      };
      
      final response = await _amenityService.createAmenity(amenityData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al crear la zona común');
      }
    } catch (e) {
      throw Exception('No se pudo crear la zona común: ${e.toString()}');
    }
  }
  
  /// Actualiza una zona común existente
  /// 
  /// @param id Identificador único de la zona común a actualizar
  /// @param name Nuevo nombre (opcional)
  /// @param description Nueva descripción (opcional)
  /// @param capacity Nueva capacidad máxima (opcional)
  /// @param status Nuevo estado (opcional)
  /// @return Objeto Amenity con los datos actualizados
  /// @throws Exception si hay un error durante la actualización
  Future<Amenity> updateAmenity(int id, {
    String? name,
    String? description,
    double? capacity,
    String? status,
  }) async {
    try {
      // Incluir solo los campos que se quieren actualizar
      final amenityData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (capacity != null) 'capacity': capacity,
        if (status != null) 'status_id': status,
      };
      
      final response = await _amenityService.updateAmenity(id, amenityData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar la zona común');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar la zona común: ${e.toString()}');
    }
  }
  
  /// Elimina una zona común
  /// 
  /// @param id Identificador único de la zona común a eliminar
  /// @return true si la eliminación fue exitosa
  /// @throws Exception si hay un error durante la eliminación
  Future<bool> deleteAmenity(int id) async {
    try {
      final response = await _amenityService.deleteAmenity(id);
      
      if (response.success && response.data != null) {
        return true;
      } else {
        throw Exception(response.message ?? 'Error al eliminar la zona común');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar la zona común: ${e.toString()}');
    }
  }
}