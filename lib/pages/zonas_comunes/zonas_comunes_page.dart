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
  List<dynamic> filteredAmenities = [];
  bool isLoading = true;
  int selectedStatusId = 1; // 1 = activas por defecto

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
            _applyFilter();
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

  void _applyFilter() {
    setState(() {
      filteredAmenities = amenities
          .where((amenity) => amenity['status_id'] == selectedStatusId)
          .toList();
    });
  }

  void _changeFilter(int statusId) {
    setState(() {
      selectedStatusId = statusId;
      _applyFilter();
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

  /// Abre formulario para reservar
  void _reservar(String amenityName, int amenityId) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController capacityController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservar $amenityName'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(labelText: 'Capacidad'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: startDateController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha/Hora inicio (YYYY-MM-DD HH:mm:ss)',
                        hintText: '2025-09-28 14:00:00'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: endDateController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha/Hora fin (YYYY-MM-DD HH:mm:ss)',
                        hintText: '2025-09-28 16:00:00'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _processReservation(
                    amenityId,
                    int.tryParse(capacityController.text) ?? 1,
                    startDateController.text,
                    endDateController.text,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// POST a backend
  Future<void> _processReservation(int amenityId, int capacity,
      String startDateTime, String endDateTime) async {
    try {
      // Formatear la fecha actual en el formato esperado
      final now = DateTime.now();
      final createAt =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('http://localhost:3000/api_v1/reservation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "amenity_id": amenityId,
          "user_id": 1, // TODO: reemplazar con id real del usuario logueado
          "status_id": 1,
          "tariff_id": 1,
          "reservation_createAt": createAt,
          "reservation_start_time": startDateTime,
          "reservation_end_time": endDateTime,
          "reservation_time_unit": 1,
          "reservation_capacity": capacity,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = json.decode(response.body);
        _showError("Error: ${data['error'] ?? 'No se pudo crear la reserva'}");
      }
    } catch (e) {
      _showError('Error de conexión al procesar la reserva: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zonas Comunes"),
      ),
      drawer: CustomDrawer(
        username: "William", // TODO: pásalo dinámico desde login
        currentIndex: 0,
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
      body: SafeArea(
        child: Column(
          children: [
            // Botones de filtros
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('Activas', 1),
                  _buildFilterButton('Inactivas', 2),
                ],
              ),
            ),

            // Lista de amenidades
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAmenities.isEmpty
                      ? Center(
                          child: Text(
                            'No hay zonas comunes ${selectedStatusId == 1 ? "activas" : "inactivas"}',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredAmenities.length,
                          itemBuilder: (context, index) {
                            final amenity = filteredAmenities[index];
                            return _buildAmenityCard(amenity);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, int statusId) {
    bool isSelected = selectedStatusId == statusId;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _changeFilter(statusId),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey,
            foregroundColor: Colors.white,
            elevation: isSelected ? 4 : 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityCard(dynamic amenity) {
    final theme = Theme.of(context);

    String amenityName =
        amenity['name']?.toString().toUpperCase() ?? 'AMENIDAD';
    String description = amenity['description'] ?? 'Sin descripción';
    int amenityId = amenity['amenity_id'] ?? 0;
    String status = amenity['status_name'] ?? 'Desconocido';

    bool isAvailable = status.toLowerCase() == 'activo' ||
        status.toLowerCase() == 'available' ||
        status.toLowerCase() == 'disponible';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amenityName,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado: $status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton(
                  onPressed: isAvailable
                      ? () => _reservar(amenityName, amenityId)
                      : null,
                  child: const Text('Reservar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
