import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';
import '../providers/auth_provider.dart'; // Added import for AuthProvider

class PropiedadesPage extends StatefulWidget {
  const PropiedadesPage({super.key});

  @override
  _PropiedadesPageState createState() => _PropiedadesPageState();
}

class _PropiedadesPageState extends State<PropiedadesPage> {
  List<dynamic> properties = [];
  List<dynamic> filteredProperties = [];
  bool isLoading = true;
  String currentFilter = 'todas'; // 'todas', 'activas', 'inactivas'

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/property'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          properties = data['data'] ?? [];
          filteredProperties = properties;
          isLoading = false;
        });
        _applyFilter(currentFilter);
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar las propiedades');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      currentFilter = filter;
      if (filter == 'todas') {
        filteredProperties = properties;
      } else if (filter == 'activas') {
        filteredProperties = properties.where((property) {
          String status =
              property['status_name']?.toString().toLowerCase() ?? '';
          return status == 'activo' ||
              status == 'active' ||
              status == 'disponible';
        }).toList();
      } else if (filter == 'inactivas') {
        filteredProperties = properties.where((property) {
          String status =
              property['status_name']?.toString().toLowerCase() ?? '';
          return status != 'activo' &&
              status != 'active' &&
              status != 'disponible';
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

  void _showPropertyDetails(dynamic property) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(property['property_name']?.toString().toUpperCase() ??
              'PROPIEDAD'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descripción: ${property['property_description'] ?? 'Sin descripción'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${property['property_type'] ?? 'Sin tipo'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Estado: ${property['status_name'] ?? 'Desconocido'}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(property['status_name']),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Creado: ${_formatDate(property['property_createAt'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Actualizado: ${_formatDate(property['property_updateAt'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    String statusLower = status.toLowerCase();
    if (statusLower == 'activo' ||
        statusLower == 'active' ||
        statusLower == 'disponible') {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Get the auth provider to access user information
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Propiedades"),
        backgroundColor: const Color(0xFF2E7D7B),
      ),
      drawer: CustomDrawer(
        username: authProvider.name ?? authProvider.username ?? "Usuario", // Dynamic username from auth provider
        currentIndex: 1, // índice de esta vista (asumiendo que propiedades es índice 1)
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/propiedades');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/clientes');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/configuraciones');
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      // Removed the "Ver Propiedades" floating button as it's not needed
      body: SafeArea(
        child: Column(
          children: [
            // Botones de filtros
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('todas', 'todas'),
                  _buildFilterButton('activas', 'activas'),
                  _buildFilterButton('inactivas', 'inactivas'),
                ],
              ),
            ),

            // Contador de propiedades
            if (!isLoading)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${filteredProperties.length} propiedades',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF2E7D7B)),
                      onPressed: fetchProperties,
                    ),
                  ],
                ),
              ),

            // Lista de propiedades
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : filteredProperties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_work_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentFilter == 'todas'
                                    ? 'No hay propiedades disponibles'
                                    : 'No hay propiedades $currentFilter',
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
                          onRefresh: fetchProperties,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredProperties.length,
                            itemBuilder: (context, index) {
                              final property = filteredProperties[index];
                              return _buildPropertyCard(property);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, String filterValue) {
    bool isSelected = currentFilter == filterValue;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _applyFilter(filterValue),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? const Color(0xFF1B4B49) : const Color(0xFF4A9B99),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(dynamic property) {
    String propertyName =
        property['property_name']?.toString().toUpperCase() ?? 'PROPIEDAD';
    String description = property['property_description'] ?? 'Sin descripción';
    String propertyType = property['property_type'] ?? 'Sin tipo';
    String status = property['status_name'] ?? 'Desconocido';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
          onTap: () => _showPropertyDetails(property),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.home_work,
                      color: Color(0xFF2E7D7B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        propertyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D7B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D7B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        propertyType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D7B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w500,
                      ),
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
