import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  _PagosPageState createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  List<dynamic> payments = [];
  List<dynamic> filteredPayments = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    fetchPayments();
    searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPayments() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/payment'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          payments = data['data'] ?? [];
          filteredPayments = payments;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar los pagos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterPayments() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty && selectedFilter == 'all') {
        filteredPayments = payments;
      } else {
        filteredPayments = payments.where((payment) {
          String reference = payment['reference']?.toString().toLowerCase() ?? '';
          String method = payment['method']?.toString().toLowerCase() ?? '';
          String amount = payment['amount_paid']?.toString() ?? '';
          String userId = payment['user_id']?.toString() ?? '';

          bool matchesSearch = query.isEmpty ||
              reference.contains(query) ||
              method.contains(query) ||
              amount.contains(query) ||
              userId.contains(query);

          bool matchesFilter = selectedFilter == 'all' ||
              _getStatusFromId(payment['status_id']) == selectedFilter;

          return matchesSearch && matchesFilter;
        }).toList();
      }
    });
  }

  String _getStatusFromId(dynamic statusId) {
    if (statusId == null) return 'unknown';
    int id = int.tryParse(statusId.toString()) ?? 0;
    switch (id) {
      case 1:
        return 'active';
      case 0:
        return 'inactive';
      default:
        return 'unknown';
    }
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

  void _showPaymentOptions(dynamic payment) {
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
                'Pago #${payment['payment_id']?.toString() ?? 'N/A'}',
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
                  _showPaymentDetails(payment);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar pago',
                onTap: () {
                  Navigator.pop(context);
                  _editPayment(payment);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar pago',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(payment);
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

  void _showPaymentDetails(dynamic payment) {
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
                backgroundColor: _getStatusColor(payment['status_id']).withOpacity(0.2),
                child: Icon(
                  Icons.payment,
                  color: _getStatusColor(payment['status_id']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pago #${payment['payment_id']}',
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
                _buildDetailRow('ID', payment['payment_id']?.toString() ?? 'N/A'),
                _buildDetailRow('Usuario ID', payment['user_id']?.toString() ?? 'N/A'),
                _buildDetailRow('Monto', _formatCurrency(payment['amount_paid'])),
                _buildDetailRow('Fecha', _formatDate(payment['payment_date'])),
                _buildDetailRow('Método', payment['method'] ?? 'No especificado'),
                _buildDetailRow('Referencia', payment['reference'] ?? 'Sin referencia'),
                _buildDetailRow('Factura ID', payment['invoice_id']?.toString() ?? 'N/A'),
                _buildDetailRow('Reserva ID', payment['reservation_id']?.toString() ?? 'N/A'),
                _buildDetailRow('Parking ID', payment['parking_assignment_id']?.toString() ?? 'N/A'),
                _buildDetailRow('Estado', _getStatusText(payment['status_id'])),
                _buildDetailRow('Tipo de Pago ID', payment['payment_type_id']?.toString() ?? 'N/A'),
                _buildDetailRow('Creado', _formatDate(payment['created_at'])),
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

  void _editPayment(dynamic payment) {
    _showCreateEditDialog(payment: payment);
  }

  void _confirmDelete(dynamic payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar el pago #${payment['payment_id']}?'),
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
                _deletePayment(payment['payment_id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePayment(int paymentId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api_v1/payment/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showSuccess('Pago eliminado correctamente');
        fetchPayments(); // Recargar la lista
      } else {
        _showError('Error al eliminar el pago');
      }
    } catch (e) {
      _showError('Error de conexión al eliminar');
    }
  }

  void _showCreateEditDialog({dynamic payment}) {
    bool isEditing = payment != null;
    
    final TextEditingController userIdController = 
        TextEditingController(text: payment?['user_id']?.toString() ?? '');
    final TextEditingController amountController = 
        TextEditingController(text: payment?['amount_paid']?.toString() ?? '');
    final TextEditingController dateController = 
        TextEditingController(text: _formatDateForInput(payment?['payment_date']));
    final TextEditingController methodController = 
        TextEditingController(text: payment?['method'] ?? '');
    final TextEditingController referenceController = 
        TextEditingController(text: payment?['reference'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Pago' : 'Nuevo Pago'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Usuario *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha *',
                    border: OutlineInputBorder(),
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: methodController,
                  decoration: const InputDecoration(
                    labelText: 'Método de Pago',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Referencia',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D7B),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
              onPressed: () {
                if (userIdController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    dateController.text.isEmpty) {
                  _showError('Los campos marcados con * son obligatorios');
                  return;
                }
                
                Navigator.of(context).pop();
                
                if (isEditing) {
                  _updatePayment(payment['payment_id'], {
                    'user_id': int.tryParse(userIdController.text) ?? 0,
                    'amount_paid': double.tryParse(amountController.text) ?? 0,
                    'payment_date': dateController.text,
                    'method': methodController.text,
                    'reference': referenceController.text,
                  });
                } else {
                  _createPayment({
                    'user_id': int.tryParse(userIdController.text) ?? 0,
                    'amount_paid': double.tryParse(amountController.text) ?? 0,
                    'payment_date': dateController.text,
                    'method': methodController.text,
                    'reference': referenceController.text,
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api_v1/payment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        _showSuccess('Pago creado correctamente');
        fetchPayments();
      } else {
        final errorData = json.decode(response.body);
        _showError(errorData['error'] ?? 'Error al crear el pago');
      }
    } catch (e) {
      _showError('Error de conexión al crear');
    }
  }

  Future<void> _updatePayment(int paymentId, Map<String, dynamic> paymentData) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/api_v1/payment/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        _showSuccess('Pago actualizado correctamente');
        fetchPayments();
      } else {
        final errorData = json.decode(response.body);
        _showError(errorData['error'] ?? 'Error al actualizar el pago');
      }
    } catch (e) {
      _showError('Error de conexión al actualizar');
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0';
    double value = double.tryParse(amount.toString()) ?? 0;
    return '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  String _formatDateForInput(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Color _getStatusColor(dynamic statusId) {
    if (statusId == null) return Colors.grey;
    int id = int.tryParse(statusId.toString()) ?? 0;
    switch (id) {
      case 1:
        return Colors.green;
      case 0:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(dynamic statusId) {
    if (statusId == null) return 'Desconocido';
    int id = int.tryParse(statusId.toString()) ?? 0;
    switch (id) {
      case 1:
        return 'Activo';
      case 0:
        return 'Inactivo';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagos"),
        backgroundColor: const Color(0xFF2E7D7B),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
                _filterPayments();
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Todos'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('Activos'),
              ),
              const PopupMenuItem(
                value: 'inactive',
                child: Text('Inactivos'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 4, // índice de pagos
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
            Navigator.pushReplacementNamed(context, '/pagos');
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
                  hintText: 'Buscar por referencia, método, monto...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D7B)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),

            // Resumen de estadísticas
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${filteredPayments.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D7B),
                          ),
                        ),
                        const Text(
                          'Total Pagos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _calculateTotalAmount(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          'Monto Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lista de pagos
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : filteredPayments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'No se encontraron pagos'
                                    : 'No hay pagos disponibles',
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
                          onRefresh: fetchPayments,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredPayments.length,
                            itemBuilder: (context, index) {
                              final payment = filteredPayments[index];
                              return _buildPaymentCard(payment);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEditDialog(),
        backgroundColor: const Color(0xFF2E7D7B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _calculateTotalAmount() {
    double total = filteredPayments.fold(0, (sum, payment) {
      double amount = double.tryParse(payment['amount_paid']?.toString() ?? '0') ?? 0;
      return sum + amount;
    });
    return _formatCurrency(total);
  }

  Widget _buildPaymentCard(dynamic payment) {
    String paymentId = payment['payment_id']?.toString() ?? 'N/A';
    String userId = payment['user_id']?.toString() ?? 'N/A';
    String amount = _formatCurrency(payment['amount_paid']);
    String method = payment['method']?.toString() ?? 'No especificado';
    String reference = payment['reference']?.toString() ?? 'Sin referencia';
    String date = _formatDate(payment['payment_date']);
    int statusId = int.tryParse(payment['status_id']?.toString() ?? '0') ?? 0;

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
          onTap: () => _showPaymentOptions(payment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor(statusId).withOpacity(0.2),
                  child: Icon(
                    Icons.payment,
                    color: _getStatusColor(statusId),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Información del pago
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pago #$paymentId',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usuario: $userId • $method',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            reference.length > 20 
                                ? '${reference.substring(0, 20)}...' 
                                : reference,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(statusId),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(statusId),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(statusId),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        date,
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
                  onPressed: () => _showPaymentOptions(payment),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}