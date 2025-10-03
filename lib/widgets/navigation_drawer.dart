/**
 * CustomDrawer
 * 
 * Este widget implementa el panel lateral de navegación de la aplicación.
 * Muestra la información del usuario actual y proporciona acceso a todas
 * las secciones principales de la aplicación.
 * 
 * El menú lateral incluye opciones para:
 * - Usuarios
 * - Propiedades
 * - Parqueaderos
 * - Visitantes
 * - Zonas comunes
 * - Y otras funcionalidades del sistema
 * 
 * También incluye una opción para cerrar la sesión del usuario.
 */
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String username;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;
  final int currentIndex;

  const CustomDrawer({
    super.key,
    required this.username,
    required this.onItemSelected,
    required this.onLogout,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  /**
   * Construye el encabezado del drawer que muestra la información del usuario
   */
  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Usuario de Pruebas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Construye la lista de opciones de menú del panel lateral
   */
  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildListTile(
          context,
          Icons.person,
          'Usuarios',
          0,
          currentIndex == 0,
        ),
        _buildListTile(
          context,
          Icons.home,
          'Propiedades',
          1,
          currentIndex == 1,
        ),
        _buildListTile(
          context,
          Icons.directions_car,
          'Parqueaderos',
          2,
          currentIndex == 2,
        ),
        _buildListTile(
          context,
          Icons.meeting_room,
          'Visitantes',
          3,
          currentIndex == 3,
        ),
        _buildListTile(
          context,
          Icons.park,
          'Zonas Comunes',
          4,
          currentIndex == 4,
        ),
        _buildListTile(
          context,
          Icons.payments,
          'Pagos',
          5,
          currentIndex == 5,
        ),
        _buildListTile(
          context,
          Icons.bar_chart,
          'Reportes',
          6,
          currentIndex == 6,
        ),
        _buildListTile(
          context,
          Icons.notifications,
          'Notificaciones',
          7,
          currentIndex == 7,
        ),
        _buildListTile(
          context,
          Icons.local_shipping,
          'Paquetes',
          8,
          currentIndex == 8,
        ),
        _buildListTile(
          context,
          Icons.feed,
          'PQRs',
          9,
          currentIndex == 9,
        ),
        _buildListTile(
          context,
          Icons.settings,
          'Configuración',
          10,
          currentIndex == 10,
        ),
        const Divider(),
        _buildLogoutTile(context),
      ],
    );
  }

  /**
   * Construye un elemento del menú con estilo personalizado
   * 
   * @param icon Icono para el elemento del menú
   * @param title Texto del elemento
   * @param index Índice asociado a la opción
   * @param isSelected Indica si este elemento está seleccionado actualmente
   */
  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.arrow_forward,
              color: Theme.of(context).primaryColor,
              size: 20,
            )
          : null,
      onTap: () {
        Navigator.pop(context); // Se cierra el panel lateral

        // Lista de rutas disponibles según el índice seleccionado
        final routes = [
          '/usuarios',
          '/propiedades',
          '/parqueaderos',
          '/visitantes',
          '/zonas-comunes',
          '/pagos',
          '/reportes',
          '/notificaciones',
          '/paquetes',
          '/pqrs',
          '/settings',
        ];

        if (index < routes.length) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
      },
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  /**
   * Construye el elemento para cerrar sesión con estilo diferenciado
   */
  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Cerrar Sesión',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () {
        Navigator.pop(context); // Se cierra el panel lateral primero
        onLogout(); // Se ejecuta la función de cierre de sesión
      },
    );
  }
}
