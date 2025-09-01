import 'package:flutter/material.dart';
import '/models/visitor.dart';
import '/widgets/base_screen.dart';
import '/widgets/items/visitor_item.dart';

class VisitorsScreens extends StatefulWidget {
  @override
  _VisitorsScreensState createState() => _VisitorsScreensState();
}

class _VisitorsScreensState extends State<VisitorsScreens> {
  final TextEditingController _searchController = TextEditingController();

  final List<Visitor> visitors = [
    Visitor(
      name: "Juan Pérez",
      type: "Visita familiar",
      homeNumber: "Casa 101 (Luis García)",
      startingHour: "10:30 AM",
      status: "ACTIVA",
    ),
    Visitor(
      name: "Ana Gómez",
      type: "Visita familiar",
      homeNumber: "Casa 102 (Carlos Ramírez)",
      startingHour: "11:00 AM",
      status: "FINALIZADA",
    ),
    Visitor(
      name: "Luisa Pereira",
      type: "Visita familiar",
      homeNumber: "Casa 104 (Pepito Pérez)",
      startingHour: "09:15 AM",
      status: "FINALIZADA",
    ),
    Visitor(
      name: "William BenavideS",
      type: "Visita Comercial",
      homeNumber: "Casa 201 (Gert Gómez)",
      startingHour: "02:30 PM",
      status: "ACTIVA",
    ),
    Visitor(
      name: "María Pantoja",
      type: "Visita familiar",
      homeNumber: "Casa 105 (Carlos Ramírez)",
      startingHour: "08:15 AM",
      status: "ACTIVA",
    ),
  ];

  List<Visitor> filteredVisitors = [];

  @override
  void initState() {
    super.initState();
    filteredVisitors = visitors;
    _searchController.addListener(_filterVisitors);
  }

  void _filterVisitors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredVisitors = visitors.where((visitor) {
        return visitor.name.toLowerCase().contains(query) ||
            visitor.type.toLowerCase().contains(query) ||
            visitor.homeNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onMenuPressed() {
    print("Menú presionado en Visitantes");
  }

  void _onNotificationPressed() {
    print("Notificaciones presionadas en Visitantes");
  }

  void _onVisitorMorePressed(Visitor visitor) {
    print("Más opciones para visitante: ${visitor.name}");
  }

  int get totalVisitors => visitors.length;
  int get activeVisits => visitors.where((v) => v.status == "ACTIVA").length;
  int get todayVisits => visitors.length; // Asumiendo que todos son de hoy

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'VISITANTES',
      onMenuPressed: _onMenuPressed,
      onNotificationPressed: _onNotificationPressed,
      child: Column(
        children: [
          // Stats cards
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFF5A9B9B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Visitantes',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          '$totalVisitors',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF7ED321),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Visitas Activas\n$activeVisits',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF5A9B9B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Visitas Hoy\n$todayVisits',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar Visitantes...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Lista de visitantes
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredVisitors.length,
              itemBuilder: (context, index) {
                final visitor = filteredVisitors[index];
                return VisitorItem(
                  visitor: visitor,
                  onMorePressed: () => _onVisitorMorePressed(visitor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
