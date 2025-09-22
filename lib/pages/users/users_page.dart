import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/user'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['data'] ?? [];
          filteredUsers = users;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar los usuarios');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) {
          String userName = user['user_name']?.toString().toLowerCase() ?? '';
          String fullName =
              user['profile_fullName']?.toString().toLowerCase() ?? '';
          String roleName = user['role_name']?.toString().toLowerCase() ?? '';
          return userName.contains(query) ||
              fullName.contains(query) ||
              roleName.contains(query);
        }).toList();
      }
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

  void _showUserOptions(dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user['user_name']?.toString() ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.visibility,
                title: 'Ver detalles',
                onTap: () {
                  Navigator.pop(context);
                  _showUserDetails(user);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar usuario',
                onTap: () {
                  Navigator.pop(context);
                  _editUser(user);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar usuario',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(user);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF2E7D7B)),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    _getStatusColor(user['status_name']).withOpacity(0.2),
                child: Text(
                  _getInitials(
                      user['user_name'] ?? user['profile_fullName'] ?? 'U'),
                  style: TextStyle(
                    color: _getStatusColor(user['status_name']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user['user_name']?.toString() ?? 'Usuario',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nombre completo',
                  user['profile_fullName'] ?? 'No disponible'),
              _buildDetailRow('Rol', user['role_name'] ?? 'No disponible'),
              _buildDetailRow('Estado', user['status_name'] ?? 'No disponible'),
              _buildDetailRow(
                  'Teléfono', user['profile_phone'] ?? 'No disponible'),
              _buildDetailRow(
                  'Email', user['profile_email'] ?? 'No disponible'),
              _buildDetailRow(
                  'Último acceso', _formatDate(user['user_lastLogin'])),
              _buildDetailRow('Creado', _formatDate(user['user_createdAt'])),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _editUser(dynamic user) {
    // Implementar navegación a pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de editar usuario en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _confirmDelete(dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar al usuario "${user['user_name']}"?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(user['user_id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api_v1/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        fetchUsers(); // Recargar la lista
      } else {
        _showError('Error al eliminar el usuario');
      }
    } catch (e) {
      _showError('Error de conexión al eliminar');
    }
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    String statusLower = status.toLowerCase();
    if (statusLower.contains('activo') || statusLower.contains('active')) {
      return Colors.green;
    } else if (statusLower.contains('inactivo') ||
        statusLower.contains('inactive')) {
      return Colors.red;
    }
    return Colors.orange;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'No disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuarios"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 2, // índice de usuarios
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/propiedades');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/usuarios');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/configuraciones');
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar Usuario...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D7B)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),

            // Lista de usuarios
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'No se encontraron usuarios'
                                    : 'No hay usuarios disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF2E7D7B),
                          onRefresh: fetchUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar navegación a crear usuario
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función de crear usuario en desarrollo'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D7B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    String userName = user['user_name']?.toString() ?? 'Usuario';
    String fullName = user['profile_fullName']?.toString() ?? userName;
    String roleName = user['role_name']?.toString() ?? 'Sin rol';
    String statusName = user['status_name']?.toString() ?? 'Desconocido';

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showUserOptions(user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor(statusName).withOpacity(0.2),
                  child: Text(
                    _getInitials(fullName),
                    style: TextStyle(
                      color: _getStatusColor(statusName),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            roleName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(statusName),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(statusName),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón de opciones
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                  onPressed: () => _showUserOptions(user),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
