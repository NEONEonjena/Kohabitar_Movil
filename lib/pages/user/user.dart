/**
 * Página de Perfil de Usuario
 * 
 * Esta pantalla muestra los datos del perfil del usuario
 * y permite realizar acciones básicas como cerrar sesión.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/appbar.dart';
import '../../pages/providers/auth_provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Se obtiene el provider de autenticación para acceder a los datos del usuario
    // Consumer escucha los cambios en el provider y reconstruye solo este widget cuando cambian
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Se extraen los datos del usuario para usarlos en la UI
        final username = authProvider.username ?? 'Usuario';
        final name = authProvider.name;
        final lastName = authProvider.lastName;
        final email = authProvider.email;
        final role = authProvider.role;
        
        // Se construye el nombre completo si está disponible
        final fullName = authProvider.user?.fullName ?? username;
        
        return Scaffold(
          // Usamos el AppBar personalizado
          appBar: const CustomAppBar(
            title: 'Mi Perfil',
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar de perfil
                _buildProfileAvatar(),
                
                const SizedBox(height: 20),
                
                // Nombre de usuario destacado
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                if (role != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Tarjeta con la información del perfil
                _buildProfileInfoCard(username, email, name, lastName),
                
                const SizedBox(height: 30),
                
                // Botones de acción
                _buildActionButtons(context, authProvider),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Se construye el avatar del perfil
  Widget _buildProfileAvatar() {
    return const Center(
      child: CircleAvatar(
        radius: 70,
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
  
  // Se construye la tarjeta con la información del perfil
  Widget _buildProfileInfoCard(String username, String? email, String? name, String? lastName) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            
            // Nombre (si existe)
            if (name != null) ...[
              _buildInfoRow(Icons.badge, 'Nombre', name),
              const SizedBox(height: 15),
            ],
            
            // Apellido (si existe)
            if (lastName != null) ...[
              _buildInfoRow(Icons.badge, 'Apellido', lastName),
              const SizedBox(height: 15),
            ],
            
            // Nombre de usuario
            _buildInfoRow(Icons.person, 'Usuario', username),
            const SizedBox(height: 15),
            
            // Email (si existe)
            _buildInfoRow(
              Icons.email,
              'Email',
              email ?? '$username@ejemplo.com',
            ),
          ],
        ),
      ),
    );
  }
  
  // Se construye una fila con un icono y dos textos
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  // Se construyen los botones de acción
  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón de editar perfil
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función de editar perfil en desarrollo')),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Editar Perfil'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Botón de cambiar contraseña
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función de cambiar contraseña en desarrollo')),
            );
          },
          icon: const Icon(Icons.key),
          label: const Text('Cambiar Contraseña'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Botón de cerrar sesión
        TextButton.icon(
          onPressed: () async {
            // Se muestra diálogo de confirmación
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            );
            
            // Si el usuario confirma, se cierra la sesión
            if (shouldLogout == true) {
              await authProvider.logout();
            }
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}