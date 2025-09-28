import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';

class PqrsPage extends StatefulWidget {
  const PqrsPage({super.key});

  @override
  _PqrsPageState createState() => _PqrsPageState();
}

class _PqrsPageState extends State<PqrsPage> {
  List<dynamic> pqrsList = [];
  List<dynamic> filteredPqrs = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPqrs();
    searchController.addListener(_filterPqrs);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPqrs() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/pqrs'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pqrsList = data['data'] ?? [];
          filteredPqrs = pqrsList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar las PQRS');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterPqrs() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPqrs = pqrsList;
      } else {
        filteredPqrs = pqrsList.where((pqrs) {
          String description = pqrs['CPCG_description']?.toString().toLowerCase() ?? '';
          String userName = pqrs['user_name']?.toString().toLowerCase() ?? '';
          String typeName = pqrs['CPCG_type_name']?.toString().toLowerCase() ?? '';
          String statusName = pqrs['status_name']?.toString().toLowerCase() ?? '';
          return description.contains(query) ||
              userName.contains(query) ||
              typeName.contains(query) ||
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

  void _showPqrsOptions(dynamic pqrs) {
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
                'PQRS #${pqrs['CPCG_id']?.toString() ?? ''}',
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
                  _showPqrsDetails(pqrs);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Actualizar estado',
                onTap: () {
                  Navigator.pop(context);
                  _updatePqrsStatus(pqrs);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit_outlined,
                title: 'Editar PQRS',
                onTap: () {
                  Navigator.pop(context);
                  _editPqrs(pqrs);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar PQRS',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(pqrs);
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

  void _showPqrsDetails(dynamic pqrs) {
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
                backgroundColor: _getTypeColor(pqrs['CPCG_type_name']).withOpacity(0.2),
                child: Icon(
                  _getTypeIcon(pqrs['CPCG_type_name']),
                  color: _getTypeColor(pqrs['CPCG_type_name']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PQRS #${pqrs['CPCG_id']?.toString() ?? ''}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Tipo', pqrs['CPCG_type_name'] ?? 'No disponible'),
                _buildDetailRow('Usuario', pqrs['user_name'] ?? 'No disponible'),
                _buildDetailRow('Propiedad', pqrs['property_name'] ?? 'No disponible'),
                _buildDetailRow('Estado', pqrs['status_name'] ?? 'No disponible'),
                _buildDetailRow('Creado', _formatDate(pqrs['CPCG_createAt'])),
                _buildDetailRow('Actualizado', _formatDate(pqrs['CPCG_updateAt'])),
                const SizedBox(height: 8),
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pqrs['CPCG_description'] ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
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
            width: 90,
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

  void _updatePqrsStatus(dynamic pqrs) {
    List<Map<String, dynamic>> statusOptions = [
      {'id': 1, 'name': 'Pendiente', 'color': Colors.orange},
      {'id': 2, 'name': 'En Proceso', 'color': Colors.blue},
      {'id': 4, 'name': 'Resuelto', 'color': Colors.green},
      {'id': 5, 'name': 'Cerrado', 'color': Colors.grey},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Actualizar Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: status['color'].withOpacity(0.2),
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: status['color'],
                  ),
                ),
                title: Text(status['name']),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateStatus(pqrs['CPCG_id'], status['id']);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(int pqrsId, int statusId) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api_v1/cpcg/$pqrsId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'Status_id': statusId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        fetchPqrs(); // Recargar la lista
      } else {
        _showError('Error al actualizar el estado');
      }
    } catch (e) {
      _showError('Error de conexión al actualizar');
    }
  }

  void _editPqrs(dynamic pqrs) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de editar PQRS en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _confirmDelete(dynamic pqrs) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar la PQRS #${pqrs['CPCG_id']}?'),
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
                _deletePqrs(pqrs['CPCG_id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePqrs(int pqrsId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api_v1/cpcg/$pqrsId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PQRS eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        fetchPqrs(); // Recargar la lista
      } else {
        _showError('Error al eliminar la PQRS');
      }
    } catch (e) {
      _showError('Error de conexión al eliminar');
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    String statusLower = status.toLowerCase();
    if (statusLower.contains('pendiente')) {
      return Colors.orange;
    } else if (statusLower.contains('proceso')) {
      return Colors.blue;
    } else if (statusLower.contains('resuelto')) {
      return Colors.green;
    } else if (statusLower.contains('cerrado')) {
      return Colors.grey;
    }
    return Colors.grey;
  }

  Color _getTypeColor(String? type) {
    if (type == null) return Colors.blue;
    String typeLower = type.toLowerCase();
    if (typeLower.contains('petición') || typeLower.contains('peticion')) {
      return Colors.blue;
    } else if (typeLower.contains('queja')) {
      return Colors.orange;
    } else if (typeLower.contains('reclamo')) {
      return Colors.red;
    } else if (typeLower.contains('sugerencia')) {
      return Colors.green;
    }
    return Colors.blue;
  }

  IconData _getTypeIcon(String? type) {
    if (type == null) return Icons.help_outline;
    String typeLower = type.toLowerCase();
    if (typeLower.contains('petición') || typeLower.contains('peticion')) {
      return Icons.request_page;
    } else if (typeLower.contains('queja')) {
      return Icons.report_problem;
    } else if (typeLower.contains('reclamo')) {
      return Icons.warning;
    } else if (typeLower.contains('sugerencia')) {
      return Icons.lightbulb_outline;
    }
    return Icons.help_outline;
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

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PQRS"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 4, // índice de PQRS
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
            Navigator.pushReplacementNamed(context, '/pqrs');
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
                  hintText: 'Buscar PQRS...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D7B)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),

            // Lista de PQRS
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : filteredPqrs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'No se encontraron PQRS'
                                    : 'No hay PQRS disponibles',
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
                          onRefresh: fetchPqrs,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredPqrs.length,
                            itemBuilder: (context, index) {
                              final pqrs = filteredPqrs[index];
                              return _buildPqrsCard(pqrs);
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
              content: Text('Función de crear PQRS en desarrollo'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D7B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPqrsCard(dynamic pqrs) {
    String pqrsId = pqrs['CPCG_id']?.toString() ?? '';
    String typeName = pqrs['CPCG_type_name']?.toString() ?? 'Sin tipo';
    String userName = pqrs['user_name']?.toString() ?? 'Sin usuario';
    String statusName = pqrs['status_name']?.toString() ?? 'Sin estado';
    String description = pqrs['CPCG_description']?.toString() ?? 'Sin descripción';
    String createDate = _formatDate(pqrs['CPCG_createAt']);

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
          onTap: () => _showPqrsOptions(pqrs),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono del tipo
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getTypeColor(typeName).withOpacity(0.2),
                  child: Icon(
                    _getTypeIcon(typeName),
                    color: _getTypeColor(typeName),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Información de la PQRS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PQRS #$pqrsId',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(statusName).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusName,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getStatusColor(statusName),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            typeName,
                            style: TextStyle(
                              fontSize: 14,
                              color: _getTypeColor(typeName),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • $userName',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _truncateText(description, 80),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                  onPressed: () => _showPqrsOptions(pqrs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}