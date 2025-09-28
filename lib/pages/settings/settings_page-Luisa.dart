import 'package:flutter/material.dart';
import 'change_email_dialog.dart';
import 'change_password_dialog.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../../widgets/navigation_drawer.dart'; // 👈 Importa tu Drawer

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        username: "Usuario Demo", // 👈 aquí pasas el usuario real
        currentIndex: 2, // 👈 índice para resaltar "Configuración" en el menú
        onItemSelected: (index) {
          Navigator.pop(context); // cerrar Drawer
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/zonasComunes');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/clientes');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Cuenta
          _buildSectionHeader(context, 'Cuenta', Icons.account_circle),
          const SizedBox(height: 8),
          _buildSettingCard(
            context: context,
            icon: Icons.email_outlined,
            title: 'Cambiar correo electrónico',
            subtitle: 'Actualiza tu correo de usuario',
            onTap: () => _showChangeEmailDialog(context),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context: context,
            icon: Icons.lock_outline,
            title: 'Cambiar contraseña',
            subtitle: 'Actualiza tu contraseña segura',
            onTap: () => _showChangePasswordDialog(context),
          ),

          const SizedBox(height: 24),

          // Sección de Apariencia
          _buildSectionHeader(context, 'Apariencia', Icons.palette_outlined),
          const SizedBox(height: 8),
          _buildThemeCard(context),
          const SizedBox(height: 8),
          _buildLanguageCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.dark_mode),
        title: const Text("Tema"),
        subtitle: const Text("Claro / Oscuro"),
        onTap: () => _openThemeDialog(context),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: const Text("Idioma"),
        subtitle: const Text("Selecciona el idioma de la app"),
        onTap: () => _openLanguageDialog(context),
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChangeEmailDialog(),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    );
  }

  void _openThemeDialog(BuildContext context) {}

  Widget _buildThemeOption() {
    return const SizedBox.shrink(); // placeholder
  }

  void _openLanguageDialog(BuildContext context) {}

  Widget _buildLanguageOption() {
    return const SizedBox.shrink();
  }

  String _getLanguageDisplayName(String languageCode) {
    return languageCode;
  }
}
