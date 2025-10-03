import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';
import '../parking/parking_main_screen.dart';

class ParqueaderosPageRefactored extends StatefulWidget {
  const ParqueaderosPageRefactored({super.key});

  @override
  _ParqueaderosPageRefactoredState createState() => _ParqueaderosPageRefactoredState();
}

class _ParqueaderosPageRefactoredState extends State<ParqueaderosPageRefactored> {
  List<dynamic> parkingZones = [];
  List<dynamic> filteredParkingZones = [];
  bool isLoading = true;
  String currentFilter = 'todas'; // 'todas', 'disponibles', 'ocupadas'
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchParkingZones();
    searchController.addListener(_filterParkingZones);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchParkingZones() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/parkingzone'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            parkingZones = data['data'] ?? [];
            _filterParkingZones();
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar las zonas de parqueo');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterParkingZones() {
    String query = searchController.text.toLowerCase();
    List<dynamic> filtered = parkingZones;

    // Aplicar filtro de búsqueda
    if (query.isNotEmpty) {
      filtered = filtered.where((zone) {
        String zoneName = zone['zone_name']?.toString().toLowerCase() ?? '';
        String zoneNumber = zone['zone_number']?.toString().toLowerCase() ?? '';
        String description = zone['description']?.toString().toLowerCase() ?? '';
        return zoneName.contains(query) ||
            zoneNumber.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Aplicar filtro de estado
    if (currentFilter != 'todas') {
      filtered = filtered.where((zone) {
        String status = zone['status_name']?.toString().toLowerCase() ?? '';
        if (currentFilter == 'disponibles') {
          return status.contains('disponible') ||
              status.contains('libre') ||
              status.contains('activo');
        } else if (currentFilter == 'ocupadas') {
          return status.contains('ocupado') ||
              status.contains('reservado') ||
              status.contains('no disponible');
        }
        return true;
      }).toList();
    }

    setState(() {
      filteredParkingZones = filtered;
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      currentFilter = filter;
    });
    _filterParkingZones();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  int _getAvailableCount() {
    return parkingZones.where((zone) {
      String status = zone['status_name']?.toString().toLowerCase() ?? '';
      return status.contains('disponible') ||
          status.contains('libre') ||
          status.contains('activo');
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parqueaderos"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 3, // índice de parqueaderos
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/propiedades');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/usuarios');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/parqueaderos');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/configuraciones');
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar zona de parqueo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Botones de filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterButton('todas', 'todas'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('disponibles', 'disponibles'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('ocupadas', 'ocupadas'),
                ),
              ],
            ),
          ),
          
          // Botón para nuevo módulo de parqueaderos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParkingMainScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_car),
                label: const Text('Nuevo Módulo de Parqueaderos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D7B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          
          // Info de conteo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${filteredParkingZones.length} zonas',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Disponibles: ${_getAvailableCount()}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          
          // Lista de zonas
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredParkingZones.isEmpty
                    ? const Center(
                        child: Text('No se encontraron zonas de parqueo'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredParkingZones.length,
                        itemBuilder: (context, index) {
                          final zone = filteredParkingZones[index];
                          return _buildParkingZoneCard(zone);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para agregar nueva zona
        },
        backgroundColor: const Color(0xFF2E7D7B),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildFilterButton(String label, String filterValue) {
    final bool isSelected = currentFilter == filterValue;
    return ElevatedButton(
      onPressed: () => _applyFilter(filterValue),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF2E7D7B) : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
  
  Widget _buildParkingZoneCard(dynamic zone) {
    final String zoneNumber = zone['zone_number'] ?? 'N/A';
    final String description = zone['description'] ?? 'Sin descripción';
    final int capacity = int.tryParse(zone['capacity']?.toString() ?? '0') ?? 0;
    final bool isActive = (zone['status_name']?.toString().toLowerCase() ?? '').contains('activo');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Zona de Parqueo #$zoneNumber',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      Text(
                        'Ubicación no especificada',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Capacidad: $capacity', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}