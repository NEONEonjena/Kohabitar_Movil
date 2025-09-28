import 'package:flutter/material.dart';
import '../widgets/navigation_drawer.dart'; // Ajusta la ruta según tu estructura
import 'zonas_comunes/zonas_comunes_page.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  String username = "Usuario Demo"; // Obtén esto de tu sistema de autenticación

  // Lista de páginas correspondientes a cada índice del drawer
  final List<Widget> pages = [
    Center(
        child: Text('Página de Usuarios',
            style: TextStyle(fontSize: 24))), // Índice 0
    Center(
        child: Text('Página de Propiedades',
            style: TextStyle(fontSize: 24))), // Índice 1
    Center(
        child: Text('Página de Parqueaderos',
            style: TextStyle(fontSize: 24))), // Índice 2
    Center(
        child: Text('Página de Visitantes',
            style: TextStyle(fontSize: 24))), // Índice 3
    ZonasComunesPage(), // Índice 4 - Tu página de zonas comunes
    Center(
        child: Text('Página de Pagos',
            style: TextStyle(fontSize: 24))), // Índice 5
    Center(
        child: Text('Página de Reportes',
            style: TextStyle(fontSize: 24))), // Índice 6
    Center(
        child: Text('Página de Notificaciones',
            style: TextStyle(fontSize: 24))), // Índice 7
    Center(
        child: Text('Página de Paquetes',
            style: TextStyle(fontSize: 24))), // Índice 8
    Center(
        child:
            Text('Página de PQRs', style: TextStyle(fontSize: 24))), // Índice 9
  ];

  // Títulos correspondientes a cada página
  final List<String> pageTitles = [
    'Usuarios',
    'Propiedades',
    'Parqueaderos',
    'Visitantes',
    'Zonas Comunes',
    'Pagos',
    'Reportes',
    'Notificaciones',
    'Paquetes',
    'PQRs',
  ];

  void _onItemSelected(int index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.pop(context); // Cierra el drawer
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Cerrar Sesión'),
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes navegar al login o hacer logout
                // Navigator.pushReplacementNamed(context, '/login');
                print('Logout realizado');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[currentIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: CustomDrawer(
        username: username,
        onItemSelected: _onItemSelected,
        onLogout: _onLogout,
        currentIndex: currentIndex,
      ),
      body: pages[
          currentIndex], // Muestra la página correspondiente al índice actual
    );
  }
}
