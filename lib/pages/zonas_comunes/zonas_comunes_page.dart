import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';

class ZonasComunesPage extends StatefulWidget {
  const ZonasComunesPage({super.key});

  @override
  _ZonasComunesPageState createState() => _ZonasComunesPageState();
}

class _ZonasComunesPageState extends State<ZonasComunesPage> {
  List<dynamic> amenities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAmenities();
  }

  Future<void> fetchAmenities() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/amenity'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            amenities = data['data'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar las amenidades');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reserva procesada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zonas Comunes"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: "William", // o pásalo dinámico si lo tienes en login
        currentIndex: 0, // índice de esta vista
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/clientes');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/configuraciones');
          }
        },
        onLogout: () {
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
                  _buildFilterButton('activas', true),
                  _buildFilterButton('inactivas', false),
                ],
              ),
            ),

            // Lista de amenidades
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : amenities.isEmpty
                      ? Center(
                          child: Text(
                            'No hay zonas comunes disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: amenities.length,
                          itemBuilder: (context, index) {
                            final amenity = amenities[index];
                            return _buildAmenityCard(amenity);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            // Implementar lógica de filtros
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

  Widget _buildAmenityCard(dynamic amenity) {
    String amenityName =
        amenity['name']?.toString().toUpperCase() ?? 'AMENIDAD';
    String description = amenity['description'] ?? 'Sin descripción';
    int amenityId = amenity['amenity_id'] ?? 0;
    String status = amenity['status_name'] ?? 'Desconocido';

    bool isAvailable = status.toLowerCase() == 'activo' ||
        status.toLowerCase() == 'available' ||
        status.toLowerCase() == 'disponible';

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
