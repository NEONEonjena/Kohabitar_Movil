import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/navigation_drawer.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  List<dynamic> notifications = [];
  List<dynamic> filteredNotifications = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'todas'; // todas, leidas, no_leidas

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    searchController.addListener(_filterNotifications);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api_v1/notification'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          notifications = data['data'] ?? [];
          filteredNotifications = notifications;
          isLoading = false;
        });
        _applyFilter();
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error al cargar las notificaciones');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error de conexión');
    }
  }

  void _filterNotifications() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredNotifications = notifications;
      } else {
        filteredNotifications = notifications.where((notification) {
          String title =
              notification['Notification_title']?.toString().toLowerCase() ??
                  '';
          String message =
              notification['Notification_message']?.toString().toLowerCase() ??
                  '';
          String type = notification['notification_type_name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return title.contains(query) ||
              message.contains(query) ||
              type.contains(query);
        }).toList();
      }
    });
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      if (selectedFilter == 'leidas') {
        filteredNotifications = filteredNotifications
            .where((notification) => _isReadNotification(notification))
            .toList();
      } else if (selectedFilter == 'no_leidas') {
        filteredNotifications = filteredNotifications
            .where((notification) => !_isReadNotification(notification))
            .toList();
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

  int _getTotalNotifications() {
    return notifications.length;
  }

  int _getUnreadNotifications() {
    return notifications
        .where((notification) => !_isReadNotification(notification))
        .length;
  }

  int _getTodayNotifications() {
    DateTime today = DateTime.now();
    return notifications.where((notification) {
      String? createTime = notification['Notification_createAt'];
      if (createTime == null) return false;
      try {
        DateTime createDate = DateTime.parse(createTime);
        return createDate.year == today.year &&
            createDate.month == today.month &&
            createDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  bool _isReadNotification(dynamic notification) {
    return notification['Status_id'] == 2 ||
        notification['status_name']?.toString().toLowerCase() == 'leida';
  }

  int _getNotificationPriority(dynamic notification) {
    return notification['Notification_priority'] ?? 2;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green; // Baja
      case 3:
        return Colors.red; // Alta
      default:
        return Colors.orange; // Media
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Baja';
      case 3:
        return 'Alta';
      default:
        return 'Media';
    }
  }

  IconData _getNotificationIcon(dynamic notification) {
    String type =
        notification['notification_type_name']?.toString().toLowerCase() ?? '';
    switch (type) {
      case 'seguridad':
        return Icons.security;
      case 'mantenimiento':
        return Icons.build;
      case 'evento':
        return Icons.event;
      case 'pago':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  void _showNotificationDetails(dynamic notification) {
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
                    _getPriorityColor(_getNotificationPriority(notification))
                        .withOpacity(0.2),
                child: Icon(
                  _getNotificationIcon(notification),
                  color:
                      _getPriorityColor(_getNotificationPriority(notification)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification['Notification_title']?.toString() ??
                      'Notificación',
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
                _buildDetailRow('Mensaje',
                    notification['Notification_message'] ?? 'Sin mensaje'),
                _buildDetailRow('Tipo',
                    notification['notification_type_name'] ?? 'General'),
                _buildDetailRow('Prioridad',
                    _getPriorityText(_getNotificationPriority(notification))),
                _buildDetailRow('Estado',
                    _isReadNotification(notification) ? 'Leída' : 'No leída'),
                _buildDetailRow('Fecha creación',
                    _formatDateTime(notification['Notification_createAt'])),
                _buildDetailRow('Última actualización',
                    _formatDateTime(notification['Notification_updateAt'])),
                if (notification['User_id'] != null)
                  _buildDetailRow('Usuario ID', '${notification['User_id']}'),
                if (notification['Property_id'] != null)
                  _buildDetailRow(
                      'Propiedad ID', '${notification['Property_id']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (!_isReadNotification(notification))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D7B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Marcar como Leída'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _markAsRead(notification);
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
            width: 120,
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

  void _markAsRead(dynamic notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marcar como Leída'),
          content: Text(
              '¿Marcar la notificación "${notification['Notification_title']}" como leída?'),
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
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _processMarkAsRead(notification);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _processMarkAsRead(dynamic notification) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:3000/api_v1/notification/${notification['Notification_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': notification['User_id'],
          'notification_title': notification['Notification_title'],
          'notification_message': notification['Notification_message'],
          'notification_type':
              notification['notification_type_name'] ?? 'general',
          'notification_status': 'read',
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Notificación marcada como leída');
        fetchNotifications();
      } else {
        _showError('Error al marcar como leída');
      }
    } catch (e) {
      _showError('Error de conexión');
    }
  }

  void _showNotificationOptions(dynamic notification) {
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
                notification['Notification_title']?.toString() ??
                    'Notificación',
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
                  _showNotificationDetails(notification);
                },
              ),
              if (!_isReadNotification(notification))
                _buildOptionTile(
                  icon: Icons.mark_email_read,
                  title: 'Marcar como leída',
                  color: const Color(0xFF2E7D7B),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsRead(notification);
                  },
                ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar notificación',
                onTap: () {
                  Navigator.pop(context);
                  _editNotification(notification);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Eliminar notificación',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(notification);
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

  void _editNotification(dynamic notification) {
    _showSuccess('Función de editar notificación en desarrollo');
  }

  void _confirmDelete(dynamic notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar la notificación "${notification['Notification_title']}"?'),
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
                _deleteNotification(
                    notification['Notification_id'] ?? notification['id']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNotification(dynamic notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api_v1/notification/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showSuccess('Notificación eliminada correctamente');
        fetchNotifications();
      } else {
        _showError('Error al eliminar la notificación');
      }
    } catch (e) {
      _showError('Error de conexión al eliminar');
    }
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

  String _getTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'hace un momento';
      }
    } catch (e) {
      return '';
    }
  }

  void _showFilterOptions() {
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
              const Text(
                'Filtrar Notificaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Todas las notificaciones', 'todas'),
              _buildFilterOption('Solo no leídas', 'no_leidas'),
              _buildFilterOption('Solo leídas', 'leidas'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, String value) {
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: selectedFilter,
        onChanged: (String? newValue) {
          setState(() {
            selectedFilter = newValue ?? 'todas';
          });
          Navigator.pop(context);
          _filterNotifications();
        },
        activeColor: const Color(0xFF2E7D7B),
      ),
      title: Text(title),
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        Navigator.pop(context);
        _filterNotifications();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: const Color(0xFF2E7D7B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNotifications,
          ),
        ],
      ),
      drawer: CustomDrawer(
        username: "William",
        currentIndex: 6, // índice de notificaciones
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
          } else if (index == 6) {
            Navigator.pushReplacementNamed(context, '/notificaciones');
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
                  // Total Notificaciones
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
                          'Total Notificaciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_getTotalNotifications()}',
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
                  // No Leídas y Hoy
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'No Leídas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getUnreadNotifications()}',
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
                                'Hoy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getTodayNotifications()}',
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
                        hintText: 'Buscar Notificaciones...',
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
                      onPressed: _showFilterOptions,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de notificaciones
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D7B),
                      ),
                    )
                  : filteredNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'No se encontraron notificaciones'
                                    : 'No hay notificaciones',
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
                          onRefresh: fetchNotifications,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = filteredNotifications[index];
                              return _buildNotificationCard(notification);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    String title =
        notification['Notification_title']?.toString() ?? 'Notificación';
    String message =
        notification['Notification_message']?.toString() ?? 'Sin mensaje';
    String timeAgo = _getTimeAgo(notification['Notification_createAt']);
    bool isRead = _isReadNotification(notification);
    int priority = _getNotificationPriority(notification);
    Color priorityColor = _getPriorityColor(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isRead
            ? null
            : Border.all(
                color: const Color(0xFF2E7D7B).withOpacity(0.2),
                width: 1,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showNotificationOptions(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono y prioridad
                Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: priorityColor.withOpacity(0.2),
                      child: Icon(
                        _getNotificationIcon(notification),
                        color: priorityColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPriorityText(priority),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Información de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isRead ? FontWeight.w500 : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D7B),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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
                  onPressed: () => _showNotificationOptions(notification),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
