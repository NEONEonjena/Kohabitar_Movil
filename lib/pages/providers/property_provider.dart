import 'package:flutter/foundation.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  String _currentFilter = 'todas'; // 'todas', 'activas', 'inactivas'
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Property> get properties => _properties;
  List<Property> get filteredProperties => _filteredProperties;
  String get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Cargar todas las propiedades
  Future<void> loadProperties() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final response = await _propertyService.getProperties();
      if (response.success) {
        _properties = response.data ?? [];
        _errorMessage = null;
        _applyFilter(_currentFilter); // Apply current filter to new data
      } else {
        _errorMessage = response.message ?? 'Error cargando propiedades';
        
        // Si no hay datos, cargamos datos de demostración para desarrollo
        if (_properties.isEmpty) {
          // Solo para desarrollo, se eliminará en producción
          if (kDebugMode) {
            print('Advertencia: Usando datos de demostración porque la API falló');
            _loadDemoProperties();
          }
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        _errorMessage = 'No se pudo conectar al servidor. Asegúrese de que el servidor API esté en ejecución.';
      } else if (e.toString().contains('Endpoint losses')) {
        _errorMessage = 'Endpoint no encontrado. Verifique la URL de la API.';
      } else {
        _errorMessage = 'Error de conexión: $e';
      }
      
      // Si no hay datos, cargamos datos de demostración para desarrollo
      if (_properties.isEmpty) {
        // Solo para desarrollo, se eliminará en producción
        if (kDebugMode) {
          print('Advertencia: Usando datos de demostración porque la API falló: $e');
          _loadDemoProperties();
        }
      }
    }
    
    _applyFilter(_currentFilter);
    _setLoading(false);
    notifyListeners();
  }
  
  // Aplicar filtro a las propiedades
  void applyFilter(String filter) {
    _currentFilter = filter;
    _applyFilter(filter);
    notifyListeners();
  }
  
  // Aplicación interna del filtro
  void _applyFilter(String filter) {
    if (filter == 'todas') {
      _filteredProperties = List.from(_properties);
    } else if (filter == 'activas') {
      _filteredProperties = _properties
          .where((property) => property.status == 'Ocupado')
          .toList();
    } else if (filter == 'inactivas') {
      _filteredProperties = _properties
          .where((property) => property.status == 'Desocupado')
          .toList();
    }
  }
  
  // Cargar propiedades de demostración para desarrollo
  void _loadDemoProperties() {
    _properties = [
      Property(
        id: 101,
        name: 'Casa 101',
        description: 'Descripción de Casa 101',
        type: 'Casa',
        status: 'Ocupado',
        owner: 'Juan Pérez',
        address: 'Casa 101, Manzana A',
        observations: '3 pisos',
      ),
      Property(
        id: 102,
        name: 'Casa 102',
        description: 'Descripción de Casa 102',
        type: 'Casa',
        status: 'Desocupado',
        owner: 'Sin propietario',
        address: 'Casa 102, Manzana A',
        observations: '2 pisos',
      ),
      Property(
        id: 103,
        name: 'Casa 103',
        description: 'Descripción de Casa 103',
        type: 'Casa',
        status: 'Ocupado',
        owner: 'María Gómez',
        address: 'Casa 103, Manzana A',
        observations: '2 pisos',
      ),
      Property(
        id: 104,
        name: 'Casa 104',
        description: 'Descripción de Casa 104',
        type: 'Casa',
        status: 'Ocupado',
        owner: 'Carlos Sánchez',
        address: 'Casa 104, Manzana A',
        observations: '3 pisos',
      ),
      Property(
        id: 105,
        name: 'Casa 105',
        description: 'Descripción de Casa 105',
        type: 'Casa',
        status: 'Ocupado',
        owner: 'Ana Martínez',
        address: 'Casa 105, Manzana B',
        observations: '2 pisos',
      ),
      Property(
        id: 106,
        name: 'Casa 106',
        description: 'Descripción de Casa 106',
        type: 'Casa',
        status: 'Ocupado',
        owner: 'Roberto López',
        address: 'Casa 106, Manzana B',
        observations: '2 pisos',
      ),
      Property(
        id: 107,
        name: 'Casa 107',
        description: 'Descripción de Casa 107',
        type: 'Casa',
        status: 'Desocupado',
        owner: 'Sin propietario',
        address: 'Casa 107, Manzana B',
        observations: '3 pisos',
      ),
      Property(
        id: 108,
        name: 'Casa 108',
        description: 'Descripción de Casa 108',
        type: 'Casa',
        status: 'Desocupado',
        owner: 'Sin propietario',
        address: 'Casa 108, Manzana B',
        observations: '2 pisos',
      ),
    ];
  }
  
  // Obtener propiedad por ID
  Future<Property?> getPropertyById(int id) async {
    try {
      final response = await _propertyService.getPropertyById(id);
      if (response.success && response.data != null) {
        return response.data;
      } else {
        _errorMessage = response.message ?? 'Error cargando la propiedad';
        return null;
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        _errorMessage = 'No se pudo conectar al servidor. Asegúrese de que el servidor API esté en ejecución.';
      } else if (e.toString().contains('Endpoint losses')) {
        _errorMessage = 'Endpoint no encontrado. Verifique la URL de la API.';
      } else {
        _errorMessage = 'Error de conexión: $e';
      }
      notifyListeners(); // Se asegura que la UI se actualice con el mensaje de error
      return null;
    }
  }
  
  // Auxiliar para actualizar el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}