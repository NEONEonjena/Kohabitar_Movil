import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ZonasComunesPage extends StatefulWidget {
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
        Uri.parse(
            'http://localhost:3000/api_v1/amenity'), // Reemplaza con tu URL base
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
    // Aquí puedes implementar la lógica de reserva
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservar'),
          content: Text('¿Deseas reservar $amenityName?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar lógica de reserva aquí
                _processReservation(amenityId);
              },
            ),
          ],
        );
      },
    );
  }

  void _processReservation(int amenityId) {
    // Implementar la llamada a la API para hacer la reserva
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva procesada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header con gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D7B), Color(0xFF4A9B99)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 24,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'ZONAS COMUNES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

            // Botones de filtros
            Container(
              margin: EdgeInsets.all(16),
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
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : amenities.isEmpty
                      ? Center(
                          child: Text(
                            'No hay amenidades disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
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
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            // Implementar lógica de filtros
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Color(0xFF1B4B49) : Color(0xFF4A9B99),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
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

    // Consideramos disponible si está "Activo"
    bool isAvailable = status.toLowerCase() == 'activo' ||
        status.toLowerCase() == 'available' ||
        status.toLowerCase() == 'disponible';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre
            Text(
              amenityName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D7B),
              ),
            ),
            SizedBox(height: 4),

            // Descripción
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),

            // Estado y botón
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
                    backgroundColor:
                        isAvailable ? Color(0xFF1B4B49) : Colors.grey[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
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

// Modelo de datos para mayor organización (opcional)
class Amenity {
  final int amenityId;
  final String amenityTypeName;
  final String propertyName;
  final String statusName;
  final String tariffType;
  final double tariffAmount;

  Amenity({
    required this.amenityId,
    required this.amenityTypeName,
    required this.propertyName,
    required this.statusName,
    required this.tariffType,
    required this.tariffAmount,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      amenityId: json['amenity_id'] ?? 0,
      amenityTypeName: json['Amenity_Type_name'] ?? '',
      propertyName: json['property_name'] ?? '',
      statusName: json['status_name'] ?? '',
      tariffType: json['tariff_type'] ?? '',
      tariffAmount: (json['tariff_amount'] ?? 0).toDouble(),
    );
  }
}
