import 'package:flutter/material.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key});

  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  // Estado actual seleccionado
  String selectedTab = "Recibidos";

  // Lista de paquetes de ejemplo
  final List<Map<String, String>> paquetes = [
    {
      "name": "William Benavidez",
      "origin": "Temu",
      "time": "2025 - 07 - 01 03:00 PM",
      "status": "Recibido"
    },
    {
      "name": "Ana María López",
      "origin": "eBay",
      "time": "2025 - 07 - 01 02:15 PM",
      "status": "Recibido"
    },
    {
      "name": "Sofía Martínez",
      "origin": "AliExpress",
      "time": "2025 - 07 - 01 01:45 PM",
      "status": "Recibido"
    },
    {
      "name": "Luis Fernández",
      "origin": "Mercado Libre",
      "time": "2025 - 07 - 01 12:30 PM",
      "status": "Recibido"
    },
    {
      "name": "María González",
      "origin": "Amazon",
      "time": "2025 - 07 - 01 11:00 AM",
      "status": "Recibido"
    },
    {
      "name": "Pedro Ramírez",
      "origin": "Shein",
      "time": "2025 - 07 - 01 10:30 AM",
      "status": "Recibido"
    },
    {
      "name": "Lucía Torres",
      "origin": "Temu",
      "time": "2025 - 07 - 01 09:45 AM",
      "status": "Recibido"
    },
    {
      "name": "Javier Sánchez",
      "origin": "eBay",
      "time": "2025 - 07 - 01 08:15 AM",
      "status": "Recibido"
    },
    {
      "name": "Elena Díaz",
      "origin": "AliExpress",
      "time": "2025 - 07 - 01 07:30 AM",
      "status": "Recibido"
    },
    {
      "name": "Miguel Álvarez",
      "origin": "Mercado Libre",
      "time": "2025 - 06 - 30 05:00 PM",
      "status": "Pendiente"
    },
    {
      "name": "Juan Gómez",
      "origin": "Amazon",
      "time": "2025 - 07 - 01 04:30 PM",
      "status": "Pendiente"
    },
    {
      "name": "Laura Pérez",
      "origin": "Shein",
      "time": "2025 - 06 - 30 04:00 PM",
      "status": "Pendiente"
    },
    {
      "name": "Diego Morales",
      "origin": "Temu",
      "time": "2025 - 06 - 30 03:15 PM",
      "status": "Pendiente"
    },
    {
      "name": "Carmen Ruiz",
      "origin": "eBay",
      "time": "2025 - 06 - 30 02:45 PM",
      "status": "Pendiente"
    },
    {
      "name": "Andrés Castillo",
      "origin": "AliExpress",
      "time": "2025 - 06 - 30 01:30 PM",
      "status": "Pendiente"
    },
    {
      "name": "Marta Flores",
      "origin": "Mercado Libre",
      "time": "2025 - 06 - 30 12:00 PM",
      "status": "Retirado"
    },
    {
      "name": "José Hernández",
      "origin": "Amazon",
      "time": "2025 - 06 - 30 11:30 AM",
      "status": "Retirado"
    },
    {
      "name": "Carlos Rivas",
      "origin": "Shein",
      "time": "2025 - 06 - 30 06:00 PM",
      "status": "Retirado"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtra los paquetes según el tab seleccionado
    List<Map<String, String>> filtered = paquetes.where((p) {
      if (selectedTab == "Recibidos") return p["status"] == "Recibido";
      if (selectedTab == "Pendientes") return p["status"] == "Pendiente";
      if (selectedTab == "Retirados") return p["status"] == "Retirado";
      return false;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Botones de tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton("Recibidos"),
              _buildTabButton("Pendientes"),
              _buildTabButton("Retirados"),
            ],
          ),
          const SizedBox(height: 10),
          // Contenido dinámico con height fijo
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No hay paquetes"))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];

                      // Definir color del card según estado
                      final cardColor = item["status"] == "Pendiente"
                          ? Colors.orange.shade50
                          : item["status"] == "Recibido"
                              ? Colors.teal.shade50
                              : Colors.green.shade50;

                      return SizedBox(
                        child: Card(
                          color: cardColor,
                          elevation: 3,
                          child: ListTile(
                            title: Text(item["name"]!),
                            subtitle:
                                Text("${item["origin"]} - ${item["time"]}"),
                            trailing: Text(
                              item["status"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item["status"] == "Recibido"
                                    ? Colors.teal
                                    : item["status"] == "Pendiente"
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Botón de selección estilo pill
  Widget _buildTabButton(String title) {
    final bool isSelected = selectedTab == title;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.teal,
        side: const BorderSide(color: Colors.teal),
        shape: const StadiumBorder(),
      ),
      onPressed: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Text(title),
    );
  }
}
