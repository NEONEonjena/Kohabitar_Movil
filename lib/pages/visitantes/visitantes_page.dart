import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';

class VisitantesPage extends StatefulWidget {
  const VisitantesPage({super.key});

  @override
  _VisitantesPageState createState() => _VisitantesPageState();
}

class _VisitantesPageState extends State<VisitantesPage> {
  List<dynamic> visitors = [];
  List<dynamic> filteredVisitors = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVisitors();
    searchController.addListener(_filterVisitors);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchVisitors() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/visitor'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          visitors = data['data'] ?? [];
          filteredVisitors = visitors;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar los visitantes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterVisitors() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredVisitors = visitors;
      } else {
        filteredVisitors = visitors.where((visitor) {
          String fullName =
              visitor['Visitor_full_name']?.toString().toLowerCase() ?? '';
          String document =
              visitor['Visitor_id_document']?.toString().toLowerCase() ?? '';
          String reason =
              visitor['Visitor_visit_reason']?.toString().toLowerCase() ?? '';
          String property =
              visitor['property_name']?.toString().toLowerCase() ?? '';
          return fullName.contains(query) ||
              document.contains(query) ||
              reason.contains(query) ||
              property.contains(query);
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  int _getTotalVisitors() {
    return visitors.length;
  }

  int _getActiveVisitors() {
    return visitors
        .where((visitor) =>
            visitor['Status_id'] == 1 ||
            visitor['status_name']?.toString().toLowerCase() == 'activo')
        .length;
  }

  int _getTodayVisitors() {
    DateTime today = DateTime.now();
    return visitors.where((visitor) {
      String? entryTime = visitor['Visitor_entry_time'];
      if (entryTime == null) return false;
      try {
        DateTime entryDate = DateTime.parse(entryTime);
        return entryDate.year == today.year &&
            entryDate.month == today.month &&
            entryDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  bool _isActiveVisitor(dynamic visitor) {
    return visitor['Status_id'] == 1 ||
        visitor['status_name']?.toString().toLowerCase() == 'activo';
  }

  void _showVisitorDetails(dynamic visitor) {
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
                backgroundColor: _isActiveVisitor(visitor)
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                child: Text(
                  _getInitials(visitor['Visitor_full_name'] ?? 'V'),
                  style: TextStyle(
                    color:
                        _isActiveVisitor(visitor) ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  visitor['Visitor_full_name']?.toString() ?? 'Visitante',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Documento', visitor['Visitor_id_document'] ?? 'N/A'),
              _buildDetailRow('Motivo',
                  visitor['Visitor_visit_reason'] ?? 'No especificado'),
              _buildDetailRow(
                  'Propiedad', visitor['property_name'] ?? 'No especificada'),
              _buildDetailRow(
                  'Autorizado por', visitor['Visitor_authorized_by'] ?? 'N/A'),
              _buildDetailRow('Hora entrada',
                  _formatDateTime(visitor['Visitor_entry_time'])),
              _buildDetailRow(
                  'Hora salida', _formatDateTime(visitor['Visitor_exit_time'])),
              _buildDetailRow(
                  'Estado', visitor['status_name'] ?? 'Desconocido'),
              if (visitor['Vehicle_id'] != null)
                _buildDetailRow('Vehículo', 'ID: ${visitor['Vehicle_id']}'),
              if (visitor['parkingSlot_id'] != null)
                _buildDetailRow(
                    'Parqueadero', 'Slot: ${visitor['parkingSlot_id']}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (_isActiveVisitor(visitor))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Marcar Salida'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _markExit(visitor);
                },
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

  void _markExit(dynamic visitor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marcar Salida'),
          content:
              Text('¿Confirmar salida de ${visitor['Visitor_full_name']}?'),
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
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _processExit(visitor);
              },
            ),
          ],
        );
      },
    );
  }

  void _processExit(dynamic visitor) {
    _showSuccess('Salida registrada correctamente');
    fetchVisitors(); // Recargar lista
  }

  void _showVisitorOptions(dynamic visitor) {
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
                visitor['Visitor_full_name']?.toString() ?? 'Visitante',
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
                  _showVisitorDetails(visitor);
                },
              ),
              if (_isActiveVisitor(visitor))
                _buildOptionTile(
                  icon: Icons.logout,
                  title: 'Marcar salida',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _markExit(visitor);
                  },
                ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar visitante',
                onTap: () {
                  Navigator.pop(context);
                  _editVisitor(visitor);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar visitante',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(visitor);
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

  void _editVisitor(dynamic visitor) {
    _showSuccess('Función de editar visitante en desarrollo');
  }

  void _confirmDelete(dynamic visitor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar el visitante "${visitor['Visitor_full_name']}"?'),
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
                _deleteVisitor(visitor['Visitor_id'] ?? visitor['id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVisitor(dynamic visitorId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api_v1/visitor/$visitorId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Visitante eliminado correctamente');
        fetchVisitors();
      } else {
        _showError('Error al eliminar el visitante');
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
    return name.isNotEmpty ? name[0].toUpperCase() : 'V';
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'No registrado';
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '--:--';
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitantes"),
        backgroundColor: const Color(0xFF2E7D7B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchVisitors,
          ),
        ],
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 4, // índice de visitantes
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/propiedades');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/usuarios');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/parqueaderos');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/visitantes');
          } else if (index == 5) {
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
            // Tarjetas de estadísticas
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Total Visitantes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D7B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Visitantes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_getTotalVisitors()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Visitas Activas y Visitas Hoy
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Visitas Activas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getActiveVisitors()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A9B99),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Visitas Hoy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getTodayVisitors()}',
                                style: const TextStyle(
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
                ],
              ),
            ),

            // Barra de búsqueda
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar Visitantes...',
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF2E7D7B)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list,
                          color: Color(0xFF2E7D7B)),
                      onPressed: () {
                        // Implementar filtros adicionales
                        _showSuccess('Filtros adicionales en desarrollo');
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de visitantes
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : filteredVisitors.isEmpty
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
                                    ? 'No se encontraron visitantes'
                                    : 'No hay visitantes registrados',
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
                          onRefresh: fetchVisitors,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredVisitors.length,
                            itemBuilder: (context, index) {
                              final visitor = filteredVisitors[index];
                              return _buildVisitorCard(visitor);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSuccess('Función de registrar visitante en desarrollo');
        },
        backgroundColor: const Color(0xFF2E7D7B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVisitorCard(dynamic visitor) {
    String visitorName =
        visitor['Visitor_full_name']?.toString() ?? 'Visitante';
    String visitReason =
        visitor['Visitor_visit_reason']?.toString() ?? 'Visita familiar';
    String property = visitor['property_name']?.toString() ??
        'Casa ${visitor['Property_id'] ?? 'N/A'}';
    String entryTime = _formatTime(visitor['Visitor_entry_time']);
    bool isActive = _isActiveVisitor(visitor);

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
          onTap: () => _showVisitorOptions(visitor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Información del visitante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visitReason,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entrada: $entryTime',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado y botón de opciones
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2E7D7B) : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'En Casa' : 'Finalizado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showVisitorOptions(visitor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
