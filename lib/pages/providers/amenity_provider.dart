/**
 * Provider de Zonas Comunes (Amenity Provider)
 * 
 * Esta clase gestiona el estado relacionado con las zonas comunes (amenidades)
 * y proporciona métodos para interactuar con ellas desde la interfaz de usuario.
 * Implementa el patrón Provider mediante ChangeNotifier para notificar a los widgets
 * cuando el estado cambia.
 * 
 * Características principales:
 * - Gestión de estado (cargando, error, datos)
 * - Operaciones CRUD completas para zonas comunes
 * - Notificación automática de cambios a la UI
 * 
 * Capa en la arquitectura: Providers (UI State Management)
 * - Depende de: AmenityRepository
 * - Utilizado por: Pages y Widgets
 */
import 'package:flutter/material.dart';
import '../../models/amenity.dart';
import '../../repositories/amenity_repository.dart';

class AmenityProvider extends ChangeNotifier {
  final AmenityRepository _amenityRepository;
  
  // Estado interno
  List<Amenity> _amenities = [];     // Lista de zonas comunes
  bool _isLoading = false;           // Indicador de carga
  String? _errorMessage;             // Mensaje de error (si existe)
  
  /**
   * Getters para acceder al estado de forma inmutable
   */
  List<Amenity> get amenities => _amenities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /**
   * Constructor del provider
   * 
   * @param amenityRepository Repositorio de zonas comunes a utilizar (opcional)
   */
  AmenityProvider({AmenityRepository? amenityRepository}) 
      : _amenityRepository = amenityRepository ?? AmenityRepository();
  
  /**
   * Obtiene todas las zonas comunes desde el repositorio
   * y actualiza el estado local
   */
  Future<void> fetchAmenities() async {
    // Actualizar estado a "cargando"
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Obtener datos del repositorio
      _amenities = await _amenityRepository.getAllAmenities();
      
      // Actualizar estado a "completado"
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Actualizar estado a "error"
      _errorMessage = 'Error al cargar zonas comunes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /**
   * Obtiene una zona común específica por su ID
   * 
   * @param id Identificador único de la zona común
   * @return La zona común encontrada o null en caso de error
   */
  Future<Amenity?> getAmenityById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final amenity = await _amenityRepository.getAmenityById(id);
      _isLoading = false;
      notifyListeners();
      return amenity;
    } catch (e) {
      _errorMessage = 'Error al cargar zona común: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /**
   * Crea una nueva zona común
   * 
   * @param name Nombre de la zona común (requerido)
   * @param description Descripción de la zona común (opcional)
   * @param capacity Capacidad máxima de personas (opcional)
   * @return La nueva zona común creada o null en caso de error
   */
  Future<Amenity?> createAmenity({
    required String name,
    String? description,
    double? capacity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Crear zona común mediante el repositorio
      final newAmenity = await _amenityRepository.createAmenity(
        name: name,
        description: description,
        capacity: capacity,
      );
      
      // Actualizar la lista local de zonas comunes
      _amenities.add(newAmenity);
      
      _isLoading = false;
      notifyListeners();
      return newAmenity;
    } catch (e) {
      _errorMessage = 'Error al crear zona común: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /**
   * Actualiza una zona común existente
   * 
   * @param id Identificador único de la zona común a actualizar
   * @param name Nuevo nombre (opcional)
   * @param description Nueva descripción (opcional)
   * @param capacity Nueva capacidad máxima (opcional)
   * @param status Nuevo estado (opcional)
   * @return true si la actualización fue exitosa, false en caso contrario
   */
  Future<bool> updateAmenity(int id, {
    String? name,
    String? description,
    double? capacity,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Actualizar mediante el repositorio
      final updatedAmenity = await _amenityRepository.updateAmenity(
        id,
        name: name,
        description: description,
        capacity: capacity,
        status: status,
      );
      
      // Actualizar la copia local en la lista de zonas comunes
      final index = _amenities.indexWhere((a) => a.id == id);
      if (index != -1) {
        _amenities[index] = updatedAmenity;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar zona común: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /**
   * Elimina una zona común
   * 
   * @param id Identificador único de la zona común a eliminar
   * @return true si la eliminación fue exitosa, false en caso contrario
   */
  Future<bool> deleteAmenity(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Eliminar mediante el repositorio
      final success = await _amenityRepository.deleteAmenity(id);
      
      if (success) {
        // Eliminar de la lista local si fue exitoso
        _amenities.removeWhere((a) => a.id == id);
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error al eliminar zona común: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}