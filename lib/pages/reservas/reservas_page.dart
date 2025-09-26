import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../widgets/navigation_drawer.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  _ReservasPageState createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  List<dynamic> reservas = [];
  bool isLoading = true;

  // Mapas para traducir ids a nombres
  final Map<int, String> amenityNames = {
    6: "Zona BBQ",
    1: "Piscina",
    2: "Gimnasio",
  };

  final Map<int, String> statusNames = {
    1: "Pendiente",
    2: "Confirmada",
    3: "Cancelada",
  };

  @override
  void initState() {
    super.initState();
    fetchReservas();
  }

  Future<void> fetchReservas() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/reservation'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          reservas = data is List ? data : [data];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showError('Error al cargar las reservas');
      }
    } catch (e) {
      setState(() => isLoading = false);
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

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "-";
    try {
      DateTime date = DateTime.parse(isoString);
      return DateFormat("dd/MM/yyyy HH:mm").format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reservas"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 5, // 👈 índice correcto de "Reservas"
        onItemSelected: (index) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/reservas');
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D7B)),
              )
            : reservas.isEmpty
                ? Center(
                    child: Text(
                      'No tienes reservas registradas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservas.length,
                    itemBuilder: (context, index) {
                      final reserva = reservas[index];
                      return _buildReservaCard(reserva);
                    },
                  ),
      ),
    );
  }

  Widget _buildReservaCard(dynamic reserva) {
    String amenityName = amenityNames[reserva['amenity_id']] ??
        "Zona común #${reserva['amenity_id']}";
    String fecha = _formatDate(reserva['reservation_createAt']);
    String inicio = _formatDate(reserva['reservation_start_time']);
    String fin = _formatDate(reserva['reservation_end_time']);
    String estado =
        statusNames[reserva['status_id']] ?? "Estado #${reserva['status_id']}";
    int capacidad = reserva['reservation_capacity'] ?? 0;

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
              amenityName.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D7B),
              ),
            ),
            const SizedBox(height: 6),
            Text("Creada: $fecha",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text("Inicio: $inicio",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text("Fin: $fin",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text("Capacidad: $capacidad personas",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(
              "Estado: $estado",
              style: TextStyle(
                fontSize: 14,
                color: estado.toLowerCase() == "confirmada"
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
