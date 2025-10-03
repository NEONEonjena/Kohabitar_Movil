import 'package:flutter/material.dart';
import './assign_vehicle_screen.dart';
import './registered_vehicles_screen.dart';
import './parking_slots_screen.dart';

class ParkingMainScreen extends StatelessWidget {
  const ParkingMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE PARQUEADEROS'),
        backgroundColor: const Color(0xFF05877C),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Icon(
                Icons.local_parking_rounded,
                size: 80,
                color: const Color(0xFF05877C),
              ),
              
              const SizedBox(height: 40),
              
              // Botón para asignar vehículo
              _buildOptionButton(
                context,
                'Asignar Vehículo',
                const Color(0xFF05877C),
                Icons.directions_car,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssignVehicleScreen(),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botón para vehículos registrados
              _buildOptionButton(
                context,
                'Vehículos Registrados',
                const Color(0xFF05877C),
                Icons.format_list_bulleted,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisteredVehiclesScreen(),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botón para parqueaderos asignados
              _buildOptionButton(
                context,
                'Parqueaderos Asignados',
                const Color(0xFF05877C),
                Icons.local_parking,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParkingSlotsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}