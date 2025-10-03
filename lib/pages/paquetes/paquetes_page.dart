import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';
import '../../config/app_theme.dart';

class PaquetesPage extends StatefulWidget {
  const PaquetesPage({super.key});

  @override
  _PaquetesPageState createState() => _PaquetesPageState();
}

class _PaquetesPageState extends State<PaquetesPage> {
  List<dynamic> packages = [];
  List<dynamic> filteredPackages = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPackages();
    searchController.addListener(_filterPackages);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPackages() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/package'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          packages = data['data'] ?? [];
          filteredPackages = packages;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar los paquetes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterPackages() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPackages = packages;
      } else {
        filteredPackages = packages.where((package) {
          String description =
              package['Package_description']?.toString().toLowerCase() ?? '';
          String userName =
              package['user_name']?.toString().toLowerCase() ?? '';
          String propertyName =
              package['property_name']?.toString().toLowerCase() ?? '';
          String statusName =
              package['status_name']?.toString().toLowerCase() ?? '';
          return description.contains(query) ||
              userName.contains(query) ||
              propertyName.contains(query) ||
              statusName.contains(query);
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

  void _showPackageOptions(dynamic package) {
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
                package['Package_description']?.toString() ?? 'Paquete',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.visibility,
                title: 'Ver detalles',
                onTap: () {
                  Navigator.pop(context);
                  _showPackageDetails(package);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar paquete',
                onTap: () {
                  Navigator.pop(context);
                  _editPackage(package);
                },
              ),
              if (package['package_exitAt'] == null)
                _buildOptionTile(
                  icon: Icons.outbox,
                  title: 'Marcar como entregado',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _markAsDelivered(package);
                  },
                ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar paquete',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(package);
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
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showPackageDetails(dynamic package) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPackageStatusColor(package['package_exitAt'])
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  package['package_exitAt'] == null
                      ? Icons.inbox
                      : Icons.outbox,
                  color: _getPackageStatusColor(package['package_exitAt']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detalles del Paquete',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Descripción',
                  package['Package_description'] ?? 'No disponible'),
              _buildDetailRow(
                  'Usuario', package['user_name'] ?? 'No disponible'),
              _buildDetailRow(
                  'Propiedad', package['property_name'] ?? 'No disponible'),
              _buildDetailRow(
                  'Estado', package['status_name'] ?? 'No disponible'),
              _buildDetailRow(
                  'Fecha de entrada', _formatDate(package['package_entryAt'])),
              _buildDetailRow(
                  'Fecha de salida', _formatDate(package['package_exitAt'])),
              _buildDetailRow(
                  'Estado del paquete',
                  package['package_exitAt'] == null
                      ? 'Pendiente'
                      : 'Entregado'),
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
            width: 110,
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

  void _editPackage(dynamic package) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de editar paquete en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _markAsDelivered(dynamic package) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar entrega'),
          content: Text(
              '¿Confirmas que el paquete "${package['Package_description']}" ha sido entregado?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Marcar como entregado'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateExitDate(package['package_id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateExitDate(int packageId) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/package/$packageId/exit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paquete marcado como entregado'),
            backgroundColor: Colors.green,
          ),
        );
        fetchPackages();
      } else {
        _showError('Error al marcar el paquete como entregado');
      }
    } catch (e) {
      _showError('Error de conexión al actualizar');
    }
  }

  void _confirmDelete(dynamic package) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar el paquete "${package['Package_description']}"?'),
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
                _deletePackage(package['package_id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePackage(int packageId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/package/$packageId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paquete eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        fetchPackages();
      } else {
        _showError('Error al eliminar el paquete');
      }
    } catch (e) {
      _showError('Error de conexión al eliminar');
    }
  }

  Color _getPackageStatusColor(String? exitDate) {
    if (exitDate == null) {
      return Colors.orange; // Pendiente
    }
    return Colors.green; // Entregado
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

  String _getPackageStatusText(String? exitDate) {
    if (exitDate == null) {
      return 'Pendiente';
    }
    return 'Entregado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paquetes"),
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 4,
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
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/paquetes');
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                decoration: InputDecoration(
                  hintText: 'Buscar Paquete...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),

            // Lista de paquetes
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : filteredPackages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'No se encontraron paquetes'
                                    : 'No hay paquetes disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.primaryColor,
                          onRefresh: fetchPackages,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredPackages.length,
                            itemBuilder: (context, index) {
                              final package = filteredPackages[index];
                              return _buildPackageCard(package);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función de crear paquete en desarrollo'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPackageCard(dynamic package) {
    String description =
        package['Package_description']?.toString() ?? 'Sin descripción';
    String userName = package['user_name']?.toString() ?? 'Usuario desconocido';
    String propertyName =
        package['property_name']?.toString() ?? 'Propiedad desconocida';
    String statusName = package['status_name']?.toString() ?? 'Sin estado';
    String entryDate = _formatDate(package['package_entryAt']);
    bool isDelivered = package['package_exitAt'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          onTap: () => _showPackageOptions(package),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono del paquete
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPackageStatusColor(package['package_exitAt'])
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDelivered ? Icons.outbox : Icons.inbox,
                    color: _getPackageStatusColor(package['package_exitAt']),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Información del paquete
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Para: $userName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Propiedad: $propertyName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getPackageStatusColor(
                                  package['package_exitAt']),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPackageStatusText(package['package_exitAt']),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPackageStatusColor(
                                  package['package_exitAt']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entryDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.4),
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
                  onPressed: () => _showPackageOptions(package),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
