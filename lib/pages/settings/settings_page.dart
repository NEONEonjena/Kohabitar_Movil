import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _showSnackBar(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Cambiar correo electrónico'),
            onTap: () {
              _showSnackBar(context, 'Acción: Cambiar correo electrónico');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Cambiar contraseña'),
            onTap: () {
              _showSnackBar(context, 'Acción: Cambiar contraseña');
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Cambio de tema'),
            onTap: () {
              _showSnackBar(context, 'Acción: Cambio de tema');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Cambio de idioma'),
            onTap: () {
              _showSnackBar(context, 'Acción: Cambio de idioma');
            },
          ),
        ],
      ),
    );
  }
}
