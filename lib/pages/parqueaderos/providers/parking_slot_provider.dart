import 'package:flutter/material.dart';
import '../../../models/parking_slot.dart';
import '../../../repositories/parking_slot_repository.dart';

// Proveedor de estado para los espacios de parqueo
class ParkingSlotProvider extends ChangeNotifier {
  final ParkingSlotRepository _repository;
  
  List<ParkingSlot> _allSlots = [];
  List<ParkingSlot> _availableSlots = [];
  List<ParkingSlot> _reservedSlots = [];
  List<ParkingSlot> _currentZoneSlots = [];
  ParkingSlot? _selectedSlot;
  
  bool _isLoading = false;
  String _errorMessage = '';
  int? _currentZoneId;
  
  ParkingSlotProvider({ParkingSlotRepository? repository})
      : _repository = repository ?? ParkingSlotRepository();
  
  // Getters
  List<ParkingSlot> get allSlots => _allSlots;
  List<ParkingSlot> get availableSlots => _availableSlots;
  List<ParkingSlot> get reservedSlots => _reservedSlots;
  List<ParkingSlot> get currentZoneSlots => _currentZoneSlots;
  ParkingSlot? get selectedSlot => _selectedSlot;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int? get currentZoneId => _currentZoneId;
  
  // Carga todos los espacios de parqueo
  Future<void> loadAllSlots() async {
    _setLoading(true);
    try {
      print('Provider - loadAllSlots: iniciando carga');
      _allSlots = await _repository.getAllParkingSlots();
      print('Provider - loadAllSlots: carga exitosa, datos: ${_allSlots.length}');
      _errorMessage = '';
    } catch (e) {
      print('Provider - loadAllSlots error: ${e.toString()}');
      _errorMessage = e.toString();
      _allSlots = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Carga los espacios disponibles
  Future<void> loadAvailableSlots() async {
    _setLoading(true);
    try {
      _availableSlots = await _repository.getAvailableSlots();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      _availableSlots = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Carga los espacios reservados
  Future<void> loadReservedSlots() async {
    _setLoading(true);
    try {
      _reservedSlots = await _repository.getReservedSlots();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      _reservedSlots = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Carga los espacios de una zona específica
  Future<void> loadSlotsByZone(int zoneId) async {
    _setLoading(true);
    _currentZoneId = zoneId;
    try {
      print('Provider - loadSlotsByZone: cargando slots para zona $zoneId');
      _currentZoneSlots = await _repository.getSlotsByZone(zoneId);
      print('Provider - loadSlotsByZone: carga exitosa, datos: ${_currentZoneSlots.length}');
      _errorMessage = '';
    } catch (e) {
      print('Provider - loadSlotsByZone error: ${e.toString()}');
      _errorMessage = e.toString();
      _currentZoneSlots = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Carga un espacio de parqueo por su ID y lo establece como seleccionado
  Future<void> loadParkingSlotById(int id) async {
    _setLoading(true);
    try {
      _selectedSlot = await _repository.getParkingSlotById(id);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      _selectedSlot = null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Establece un espacio de parqueo como seleccionado
  void setSelectedSlot(ParkingSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }
  
  // Crea un nuevo espacio de parqueo
  Future<bool> createParkingSlot(ParkingSlot parkingSlot) async {
    _setLoading(true);
    try {
      final createdSlot = await _repository.createParkingSlot(parkingSlot);
      // Actualiza las listas si es necesario
      _allSlots = [..._allSlots, createdSlot];
      if (_currentZoneId == createdSlot.parkingZoneId) {
        _currentZoneSlots = [..._currentZoneSlots, createdSlot];
      }
      if (!createdSlot.isReserved) {
        _availableSlots = [..._availableSlots, createdSlot];
      } else {
        _reservedSlots = [..._reservedSlots, createdSlot];
      }
      _errorMessage = '';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Actualiza un espacio de parqueo existente
  Future<bool> updateParkingSlot(ParkingSlot parkingSlot) async {
    _setLoading(true);
    try {
      final updatedSlot = await _repository.updateParkingSlot(parkingSlot);
      // Actualiza las listas
      _updateSlotInLists(updatedSlot);
      _errorMessage = '';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Elimina un espacio de parqueo
  Future<bool> deleteParkingSlot(int id) async {
    _setLoading(true);
    try {
      final success = await _repository.deleteParkingSlot(id);
      if (success) {
        // Elimina el espacio de parqueo de las listas
        _removeSlotFromLists(id);
        _errorMessage = '';
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Métodos auxiliares privados
  
  // Actualiza el estado de carga y notifica a los oyentes
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Actualiza un espacio de parqueo en todas las listas
  void _updateSlotInLists(ParkingSlot updatedSlot) {
    // Actualiza en la lista de todos los espacios
    _allSlots = _allSlots.map((slot) => 
        slot.id == updatedSlot.id ? updatedSlot : slot).toList();
    
    // Actualiza en la lista de la zona actual si corresponde
    if (_currentZoneId == updatedSlot.parkingZoneId) {
      _currentZoneSlots = _currentZoneSlots.map((slot) => 
          slot.id == updatedSlot.id ? updatedSlot : slot).toList();
    } else if (_currentZoneId != null) {
      // Si cambió la zona, quítalo de la lista actual
      _currentZoneSlots = _currentZoneSlots.where((slot) => 
          slot.id != updatedSlot.id).toList();
    }
    
    // Actualiza en las listas de disponibles y reservados según corresponda
    if (updatedSlot.isReserved) {
      _availableSlots = _availableSlots.where((slot) => 
          slot.id != updatedSlot.id).toList();
      
      // Solo agregar a reservados si no está ya
      if (!_reservedSlots.any((slot) => slot.id == updatedSlot.id)) {
        _reservedSlots = [..._reservedSlots, updatedSlot];
      } else {
        _reservedSlots = _reservedSlots.map((slot) => 
            slot.id == updatedSlot.id ? updatedSlot : slot).toList();
      }
    } else {
      _reservedSlots = _reservedSlots.where((slot) => 
          slot.id != updatedSlot.id).toList();
          
      // Solo agregar a disponibles si no está ya
      if (!_availableSlots.any((slot) => slot.id == updatedSlot.id)) {
        _availableSlots = [..._availableSlots, updatedSlot];
      } else {
        _availableSlots = _availableSlots.map((slot) => 
            slot.id == updatedSlot.id ? updatedSlot : slot).toList();
      }
    }
    
    // Si el espacio seleccionado fue actualizado, actualiza la referencia
    if (_selectedSlot != null && _selectedSlot!.id == updatedSlot.id) {
      _selectedSlot = updatedSlot;
    }
    
    notifyListeners();
  }
  
  // Elimina un espacio de parqueo de todas las listas
  void _removeSlotFromLists(int id) {
    _allSlots = _allSlots.where((slot) => slot.id != id).toList();
    _currentZoneSlots = _currentZoneSlots.where((slot) => slot.id != id).toList();
    _availableSlots = _availableSlots.where((slot) => slot.id != id).toList();
    _reservedSlots = _reservedSlots.where((slot) => slot.id != id).toList();
    
    // Si el espacio seleccionado fue eliminado, limpia la referencia
    if (_selectedSlot != null && _selectedSlot!.id == id) {
      _selectedSlot = null;
    }
    
    notifyListeners();
  }
}