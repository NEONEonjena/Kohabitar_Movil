import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';
import '../../config/app_theme.dart';

class ParqueaderosPage extends StatefulWidget {
  const ParqueaderosPage({super.key});

  @override
  _ParqueaderosPageState createState() => _ParqueaderosPageState();
}

class _ParqueaderosPageState extends State<ParqueaderosPage> {
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
            filteredParkingZones = parkingZones;
            isLoading = false;
          });
          _applyFilter(currentFilter);
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
        String description =
            zone['description']?.toString().toLowerCase() ?? '';
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showParkingZoneDetails(dynamic parkingZone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.local_parking,
                color: _getStatusColor(parkingZone['status_name']),
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  parkingZone['zone_name']?.toString() ?? 'Zona de Parqueo',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Número', parkingZone['zone_number']?.toString() ?? 'N/A'),
              _buildDetailRow('Descripción',
                  parkingZone['description'] ?? 'Sin descripción'),
              _buildDetailRow(
                  'Estado', parkingZone['status_name'] ?? 'Desconocido'),
              _buildDetailRow(
                  'Ubicación', parkingZone['location'] ?? 'No especificada'),
              _buildDetailRow(
                  'Capacidad', _getCapacityString(parkingZone['capacity'])),
              _buildDetailRow(
                  'Tipo', parkingZone['zone_type'] ?? 'No especificado'),
              _buildDetailRow('Creado', _formatDate(parkingZone['created_at'])),
              _buildDetailRow(
                  'Actualizado', _formatDate(parkingZone['updated_at'])),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (_isAvailable(parkingZone['status_name']))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reservar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _reserveParkingZone(parkingZone);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _reserveParkingZone(dynamic parkingZone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Reserva'),
          content: Text(
              '¿Deseas reservar la zona de parqueo "${parkingZone['zone_name'] ?? 'N/A'}" #${parkingZone['zone_number'] ?? 'N/A'}?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _processReservation(parkingZone);
              },
            ),
          ],
        );
      },
    );
  }

  void _processReservation(dynamic parkingZone) {
    // Aquí podrías implementar la lógica de reserva real
    _showSuccess('Zona de parqueo reservada correctamente');
  }

  void _showParkingZoneOptions(dynamic parkingZone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${parkingZone['zone_name'] ?? 'Zona'} #${parkingZone['zone_number'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.visibility,
                title: 'Ver detalles',
                onTap: () {
                  Navigator.pop(context);
                  _showParkingZoneDetails(parkingZone);
                },
              ),
              if (_isAvailable(parkingZone['status_name']))
                _buildOptionTile(
                  icon: Icons.book_online,
                  title: 'Reservar zona',
                  onTap: () {
                    Navigator.pop(context);
                    _reserveParkingZone(parkingZone);
                  },
                ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar zona',
                onTap: () {
                  Navigator.pop(context);
                  _editParkingZone(parkingZone);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar zona',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(parkingZone);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: color ??
              (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _editParkingZone(dynamic parkingZone) {
    _showSuccess('Función de editar zona en desarrollo');
  }

  void _confirmDelete(dynamic parkingZone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar la zona "${parkingZone['zone_name']}" #${parkingZone['zone_number']}?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteParkingZone(
                    parkingZone['id'] ?? parkingZone['zone_id'] ?? '0');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteParkingZone(dynamic zoneId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api_v1/parkingzone/$zoneId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSuccess('Zona de parqueo eliminada correctamente');
          fetchParkingZones();
        } else {
          _showError(data['message'] ?? 'Error al eliminar');
        }
      } else {
        _showError('Error al eliminar la zona de parqueo');
      }
    } catch (e) {
      _showError('Error de conexión al eliminar');
    }
  }

  bool _isAvailable(String? status) {
    if (status == null) return false;
    String statusLower = status.toLowerCase();
    return statusLower.contains('disponible') ||
        statusLower.contains('libre') ||
        statusLower.contains('activo');
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    String statusLower = status.toLowerCase();
    if (statusLower.contains('disponible') ||
        statusLower.contains('libre') ||
        statusLower.contains('activo')) {
      return Colors.green;
    } else if (statusLower.contains('ocupado') ||
        statusLower.contains('reservado')) {
      return Colors.red;
    } else if (statusLower.contains('mantenimiento')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getCapacityString(dynamic capacity) {
    if (capacity == null) return 'N/A vehículos';

    if (capacity is int) {
      return '$capacity vehículos';
    } else if (capacity is String) {
      final parsed = int.tryParse(capacity);
      return parsed != null ? '$parsed vehículos' : '$capacity vehículos';
    }

    return '$capacity vehículos';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'No disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parqueaderos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchParkingZones,
          ),
        ],
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar zona de parqueo...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),

            // Botones de filtros
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('todas', 'todas'),
                  _buildFilterButton('disponibles', 'disponibles'),
                  _buildFilterButton('ocupadas', 'ocupadas'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contador y información
            if (!isLoading)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${filteredParkingZones.length} zonas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Disponibles: ${_getAvailableCount()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Lista de zonas de parqueo
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.secondaryColor,
                      ),
                    )
                  : filteredParkingZones.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_parking,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchController.text.isNotEmpty ||
                                        currentFilter != 'todas'
                                    ? 'No se encontraron zonas de parqueo'
                                    : 'No hay zonas de parqueo disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.secondaryColor,
                          onRefresh: fetchParkingZones,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredParkingZones.length,
                            itemBuilder: (context, index) {
                              final parkingZone = filteredParkingZones[index];
                              return _buildParkingZoneCard(parkingZone);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSuccess('Función de crear zona en desarrollo');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  int _getAvailableCount() {
    return filteredParkingZones
        .where((zone) => _isAvailable(zone['status_name']))
        .length;
  }

  Widget _buildFilterButton(String text, String filterValue) {
    bool isSelected = currentFilter == filterValue;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _applyFilter(filterValue),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? AppTheme.primaryColor : AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParkingZoneCard(dynamic parkingZone) {
    String zoneName = parkingZone['zone_name']?.toString() ?? 'Zona de Parqueo';
    String zoneNumber = parkingZone['zone_number']?.toString() ?? 'N/A';
    String description = parkingZone['description'] ?? 'Sin descripción';
    String status = parkingZone['status_name'] ?? 'Desconocido';
    String location = parkingZone['location'] ?? 'Ubicación no especificada';
    dynamic capacityValue = parkingZone['capacity'] ?? 0;
    int capacity = 0;

    // Manejar la capacidad que puede venir como string o int
    if (capacityValue is int) {
      capacity = capacityValue;
    } else if (capacityValue is String) {
      capacity = int.tryParse(capacityValue) ?? 0;
    }

    bool isAvailable = _isAvailable(status);
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showParkingZoneOptions(parkingZone),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_parking,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$zoneName #$zoneNumber',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showParkingZoneOptions(parkingZone),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Capacidad: $capacity',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
