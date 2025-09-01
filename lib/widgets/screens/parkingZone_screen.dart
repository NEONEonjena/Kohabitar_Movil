import 'package:flutter/material.dart';
import '/widgets/base_screen.dart';
import '/widgets/buttons/parkingZone_button.dart';

class ParkingZoneScreen extends StatefulWidget {
  @override
  _ParkingZoneScreenState createState() => _ParkingZoneScreenState();
}

class _ParkingZoneScreenState extends State<ParkingZoneScreen> {
  void _onMenuPressed() {
    print("Menú presionado en Parqueadero");
  }

  void _onNotificationPressed() {
    print("Notificaciones presionadas en Parqueadero");
  }

  void _onRegistroVehiculosPressed() {
    print("Registro de Vehículos presionado");
    // Navegar a la pantalla de registro de vehículos
  }

  void _onAsignacionParqueaderosPressed() {
    print("Asignación de Parqueaderos presionado");
    // Navegar a la pantalla de asignación de parqueaderos
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'PARQUEADERO',
      onMenuPressed: _onMenuPressed,
      onNotificationPressed: _onNotificationPressed,
      child: Column(
        children: [
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Expanded(
                  child: ParkingZoneButton(
                    title: 'REGISTRO DE\nVEHÍCULOS',
                    onTap: _onRegistroVehiculosPressed,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ParkingZoneButton(
                    title: 'ASIGNACIÓN DE\nPARQUEADEROS',
                    onTap: _onAsignacionParqueaderosPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
