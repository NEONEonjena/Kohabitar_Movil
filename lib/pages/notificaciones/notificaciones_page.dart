import 'package:flutter/material.dart';
import '../../widgets/navigation_drawer.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final List<_NotificacionItem> _items = [
    _NotificacionItem(
      'Parqueaderos',
      'Mensaje para notificaciones de parqueaderos.....',
      [
        'Su vehículo ha sido registrado en el parqueadero.',
        'El espacio de parqueadero estará disponible hasta las 6:00 PM.',
        'Recordatorio: Su tiempo de parqueo vence en 30 minutos.'
      ],
    ),
    _NotificacionItem(
      'Pagos',
      'Mensaje para notificaciones de pagos (administración, multas, zonas comunes...)',
      [
        'Su pago de administración ha sido procesado exitosamente.',
        'Tiene una multa pendiente por pagar antes del día 15.',
        'El recibo de zonas comunes está disponible para descargar.'
      ],
    ),
    _NotificacionItem(
      'Entrega de paquetes',
      'Mensaje para notificaciones de entrega de paquetes...',
      [
        'Tiene un paquete esperando en la portería.',
        'Su paquete será entregado hoy entre 2:00 PM y 5:00 PM.',
        'Paquete entregado exitosamente en su apartamento.'
      ],
    ),
    _NotificacionItem(
      'Fecha de pago',
      'Mensaje para notificaciones de fechas de pago...',
      [
        'Recordatorio: Su pago vence en 3 días.',
        'Su fecha de pago ha sido extendida hasta el día 20.',
        'Pago vencido. Por favor regularice su situación.'
      ],
    ),
    _NotificacionItem(
      'Mantenimientos preventivos',
      'Mensaje para notificaciones de mantenimientos preventivos...',
      [
        'Mantenimiento programado para el ascensor el próximo lunes.',
        'Se realizará limpieza de tanques de agua este fin de semana.',
        'Mantenimiento de aires acondicionados completado.'
      ],
    ),
    _NotificacionItem(
      'Estado de PQRS',
      'Mensaje para notificaciones de estado de PQRS...',
      [
        'Su PQRS ha sido recibida y está en proceso de revisión.',
        'Su solicitud ha sido resuelta satisfactoriamente.',
        'Necesitamos información adicional para procesar su PQRS.'
      ],
    ),
    _NotificacionItem(
      'Asambleas y reuniones',
      'Mensaje para notificaciones de asambleas y reuniones...',
      [
        'Asamblea general programada para el próximo sábado a las 10:00 AM.',
        'Reunión extraordinaria convocada para tratar temas urgentes.',
        'Los resultados de la asamblea están disponibles en cartelera.'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      drawer: CustomDrawer(
        username: "William", // TODO: pásalo dinámico desde login
        currentIndex: 0,
        onItemSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonas');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/clientes');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/configuraciones');
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                title: Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(item.subtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: item.enabled,
                      onChanged: (val) {
                        setState(() => item.enabled = val);
                      },
                      activeThumbColor: Theme.of(context).primaryColor,
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  // Navegar a la página de edición de mensajes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarMensajesPage(
                        categoria: item.title,
                        mensajes: List<String>.from(item.mensajes),
                        onGuardar: (nuevosMensajes) {
                          setState(() {
                            item.mensajes = nuevosMensajes;
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificacionItem {
  final String title;
  final String subtitle;
  bool enabled;
  List<String> mensajes;

  _NotificacionItem(this.title, this.subtitle, this.mensajes) : enabled = true;
}

class EditarMensajesPage extends StatefulWidget {
  final String categoria;
  final List<String> mensajes;
  final Function(List<String>) onGuardar;

  const EditarMensajesPage({
    super.key,
    required this.categoria,
    required this.mensajes,
    required this.onGuardar,
  });

  @override
  _EditarMensajesPageState createState() => _EditarMensajesPageState();
}

class _EditarMensajesPageState extends State<EditarMensajesPage> {
  late List<TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los mensajes actuales
    _controllers = widget.mensajes
        .map((mensaje) => TextEditingController(text: mensaje))
        .toList();
  }

  @override
  void dispose() {
    // Limpiar los controladores
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      // Obtener los nuevos mensajes de los controladores
      List<String> nuevosMensajes =
          _controllers.map((controller) => controller.text.trim()).toList();

      // Llamar al callback para actualizar los mensajes
      widget.onGuardar(nuevosMensajes);

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensajes guardados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Regresar a la pantalla anterior
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.categoria}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mensajes de notificación para ${widget.categoria}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Edita los mensajes que se mostrarán en las notificaciones:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mensaje ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _controllers[index],
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Ingresa el mensaje de notificación...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Este campo no puede estar vacío';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'El mensaje debe tener al menos 10 caracteres';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
