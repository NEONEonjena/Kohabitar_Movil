import 'package:flutter/material.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final List<_NotificacionItem> _items = [
    _NotificacionItem(
        'Parqueaderos', 'Mensaje para notificaciones de parqueaderos.....'),
    _NotificacionItem('Pagos',
        'Mensaje para notificaciones de pagos (administración, multas, zonas comunes...)'),
    _NotificacionItem('Entrega de paquetes',
        'Mensaje para notificaciones de entrega de paquetes...'),
    _NotificacionItem(
        'Fecha de pago', 'Mensaje para notificaciones de fechas de pago...'),
    _NotificacionItem('Mantenimientos preventivos',
        'Mensaje para notificaciones de mantenimientos preventivos...'),
    _NotificacionItem(
        'Estado de PQRS', 'Mensaje para notificaciones de estado de PQRS...'),
    _NotificacionItem('Mantenimientos preventivos',
        'Mensaje para notificaciones de mantenimientos preventivos...'),
    _NotificacionItem('Asambleas y reuniones',
        'Mensaje para notificaciones de mantenimientos preventivos...'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
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
                trailing: Switch(
                  value: item.enabled,
                  onChanged: (val) {
                    setState(() => item.enabled = val);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
  _NotificacionItem(this.title, this.subtitle) : enabled = true;
}
