import 'package:flutter/material.dart';
import 'change_email_dialog.dart';
import 'change_password_dialog.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/navigation_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      drawer: CustomDrawer(
        username: "Usuario Demo",
        currentIndex: 2,
        onItemSelected: (index) {
          Navigator.pop(context);
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
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: ListView(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    String currentTheme;
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        currentTheme = 'Claro';
        break;
      case ThemeMode.dark:
        currentTheme = 'Oscuro';
        break;
      case ThemeMode.system:
        currentTheme = 'Sistema';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _openThemeDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: theme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tema",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTheme,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
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

  void _openThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                'Claro',
                Icons.light_mode,
                ThemeMode.light,
                themeProvider.themeMode == ThemeMode.light,
                () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              _buildThemeOption(
                context,
                'Oscuro',
                Icons.dark_mode,
                ThemeMode.dark,
                themeProvider.themeMode == ThemeMode.dark,
                () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              _buildThemeOption(
                context,
                'Sistema',
                Icons.settings_suggest,
                ThemeMode.system,
                themeProvider.themeMode == ThemeMode.system,
                () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.primaryColor : null,
      ),
      title: Text(label),
      trailing:
          isSelected ? Icon(Icons.check, color: theme.primaryColor) : null,
      onTap: onTap,
    );
  }
}
