import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes de la Aplicación',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Cuenta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(.6),
              ),
            ),
            const SizedBox(height: 20),
            // Ejemplo de configuración
            settingsCard(
              context,
              title: 'Cambiar Email',
              subtitle: 'Establecer tu dirección de correo electrónico',
              icon: Icons.email,
            
            ),
            settingsCard(
              context,
              title: 'Cambiar Contraseña',
              subtitle: 'Establece una nueva contraseña segura',
              icon: Icons.lock,
            
            ),
            Text(
              'Apariencia',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(.6),
              ),
            ),
            settingsCard(
              context,
              title: 'Tema',
              subtitle: 'Personaliza colores y aspecto',
              icon: Icons.color_lens,
            ),
            settingsCard(
              context,
              title: 'Idioma',
              subtitle: 'Selecciona el idioma de la aplicación',
              icon: Icons.language,
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(icon, color: scheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.0,
          color: scheme.onSurface.withOpacity(.6),
        ),
        onTap: onTap ?? () => _showTitleDialog(context, title),
      ),
    );
  }

  void _showTitleDialog(BuildContext context, String title, ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('Has abierto la opción: "$title"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
