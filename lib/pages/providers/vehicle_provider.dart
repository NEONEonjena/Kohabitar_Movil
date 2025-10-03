import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _vehicleService;
  bool _isLoading = false;
  List<Vehicle> _vehicles = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<Vehicle> get vehicles => _vehicles;
  String? get error => _error;

  // Constructor
  VehicleProvider({VehicleService? vehicleService}) 
      : _vehicleService = vehicleService ?? VehicleService();

  // Cargar todos los vehículos
  Future<void> loadVehicles() async {
    _setLoading(true);
    
    try {
      final response = await _vehicleService.getVehicles();
      
      if (response.success) {
        _vehicles = response.data ?? [];
        _error = null;
      } else {
        _error = response.message ?? 'Error al cargar los vehículos';
      }
    } catch (e) {
      _error = 'Error al cargar los vehículos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Cargar vehículos por propiedad
  Future<void> loadVehiclesByProperty(int propertyId) async {
    _setLoading(true);
    
    try {
      final response = await _vehicleService.getVehiclesByProperty(propertyId);
      
      if (response.success) {
        _vehicles = response.data ?? [];
        _error = null;
      } else {
        _error = response.message ?? 'Error al cargar los vehículos de la propiedad';
      }
    } catch (e) {
      _error = 'Error al cargar los vehículos de la propiedad: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Obtener vehículos filtrados por propiedad
  List<Vehicle> getVehiclesByProperty(String propertyId) {
    if (propertyId.isEmpty) return [];
    return _vehicles.where((v) => v.propertyName == propertyId).toList();
  }

  // Obtener un vehículo por su ID
  Vehicle? getVehicleById(String id) {
    if (id.isEmpty) return null;
    try {
      return _vehicles.firstWhere((v) => v.plate == id);
    } catch (e) {
      return null;
    }
  }

  // Crear un nuevo vehículo
  Future<bool> createVehicle(Vehicle vehicle) async {
    _setLoading(true);
    
    try {
      final response = await _vehicleService.createVehicle(vehicle.toJson());
      
      if (response.success) {
        await loadVehicles(); // Recargar la lista después de crear
        return true;
      } else {
        _error = response.message ?? 'Error al crear el vehículo';
        return false;
      }
    } catch (e) {
      _error = 'Error al crear el vehículo: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Asignar un vehículo a un parqueadero
  Future<bool> assignParkingSlot(String vehicleId, String parkingSlotId) async {
    _setLoading(true);
    
    try {
      final updateData = {
        'parkingSlot_code': parkingSlotId
      };
      
      final response = await _vehicleService.assignVehicleToParkingSlot(vehicleId, updateData);
      
      if (response.success) {
        await loadVehicles(); // Recargar la lista después de actualizar
        return true;
      } else {
        _error = response.message ?? 'Error al asignar parqueadero';
        return false;
      }
    } catch (e) {
      _error = 'Error al asignar parqueadero: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar un vehículo
  Future<bool> deleteVehicle(String vehicleId) async {
    _setLoading(true);
    
    try {
      final response = await _vehicleService.deleteVehicle(vehicleId);
      
      if (response.success) {
        _vehicles.removeWhere((v) => v.plate == vehicleId);
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al eliminar el vehículo';
        return false;
      }
    } catch (e) {
      _error = 'Error al eliminar el vehículo: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método auxiliar para actualizar el estado de carga y notificar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}