import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/amenity.dart';
import '../../pages/providers/amenity_provider.dart';
import '../../pages/providers/auth_provider.dart';
import '../../widgets/navigation_drawer.dart';

class ZonasComunesPage extends StatefulWidget {
  const ZonasComunesPage({super.key});

  @override
  _ZonasComunesPageState createState() => _ZonasComunesPageState();
}

class _ZonasComunesPageState extends State<ZonasComunesPage> {
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    // Cargar las amenidades al iniciar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AmenityProvider>(context, listen: false).fetchAmenities();
    });
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

  void _reservar(String amenityName, int amenityId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reservar'),
          content: Text('¿Deseas reservar $amenityName?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _processReservation(amenityId);
              },
            ),
          ],
        );
      },
    );
  }

  void _processReservation(int amenityId) {
    // En una versión futura, aquí se implementará la lógica de reservas
    // usando un repositorio y provider específico para reservas
    _showSuccess('Reserva procesada correctamente');
  }

  @override
  Widget build(BuildContext context) {
    // Obtener datos del provider de autenticación para el drawer
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.username ?? 'Usuario';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zonas Comunes"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: username,
        currentIndex: 0,
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas-comunes');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/propiedades');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
        onLogout: () {
          authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Botones de filtros
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('activas', _showActiveOnly),
                  _buildFilterButton('inactivas', !_showActiveOnly),
                ],
              ),
            ),

            // Lista de amenidades usando Provider
            Expanded(
              child: Consumer<AmenityProvider>(
                builder: (context, amenityProvider, child) {
                  if (amenityProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    );
                  }
                  
                  if (amenityProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            amenityProvider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              amenityProvider.fetchAmenities();
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Filtrar amenidades según el filtro activo
                  final filteredAmenities = amenityProvider.amenities.where((amenity) {
                    return _showActiveOnly ? amenity.isAvailable : !amenity.isAvailable;
                  }).toList();
                  
                  if (filteredAmenities.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay zonas comunes ${_showActiveOnly ? 'disponibles' : 'inactivas'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredAmenities.length,
                    itemBuilder: (context, index) {
                      final amenity = filteredAmenities[index];
                      return _buildAmenityCard(amenity);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refrescar datos
          Provider.of<AmenityProvider>(context, listen: false).fetchAmenities();
        },
        backgroundColor: const Color(0xFF1B4B49),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showActiveOnly = text == 'activas';
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isActive ? const Color(0xFF1B4B49) : const Color(0xFF4A9B99),
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

  Widget _buildAmenityCard(Amenity amenity) {
    String amenityName = amenity.name.toUpperCase();
    String description = amenity.description ?? 'Sin descripción';
    int amenityId = amenity.id;
    String status = amenity.status ?? 'Desconocido';
    bool isAvailable = amenity.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amenityName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D7B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado: $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton(
                  onPressed: isAvailable
                      ? () => _reservar(amenityName, amenityId)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable
                        ? const Color(0xFF1B4B49)
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Reservar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
