import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/providers/auth_provider.dart';
import '../pages/splash/splash_app.dart';
import '../pages/auth/login.dart';
import '../pages/settings/settings_page.dart';
import '../pages/home/home.dart';
import '../pages/zonas_comunes/zonas_comunes_page.dart';
import '../pages/propiedades/propiedades_page.dart';
import '../pages/users/users_page.dart';
import '../pages/parqueaderos/parqueaderos_page.dart';
import '../pages/visitantes/visitantes_page.dart';
import '../pages/notificaciones/notificaciones_page.dart';
import '../pages/reservas/reservas_page.dart';
import '../pages/paquetes/paquetes_page.dart';
import '../pages/pagos/pagos_page.dart';
import '../pages/pqrs/pqrs_page.dart';

class AppRoutes {
  // Definición de rutas
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String zonaComunes = '/zonas-comunes';
  static const String propiedades = '/propiedades';
  static const String settings = '/settings';
  static const String usuarios = '/usuarios';
  static const String parqueaderos = '/parqueaderos';
  static const String visitantes = '/visitantes';
  static const String notificaciones = '/notificaciones';
  static const String reportes = '/reportes';
  static const String reservas = '/reservas';
  static const String paquetes = '/paquetes';
  static const String pagos = '/pagos';
  static const String pqrs = '/pqrs';
  

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashApp(),
        login: (context) => const LoginPage(),
        home: (context) => const HomePage(),
        zonaComunes: (context) => ZonasComunesPage(),
        settings: (context) => const SettingsPage(),
        propiedades: (context) => const PropiedadesPage(),
        usuarios: (context) => const UsuariosPage(),
        parqueaderos: (context) => const ParqueaderosPage(),
        visitantes: (context) => const VisitantesPage(),
        notificaciones: (context) => const NotificacionesPage(),
        reservas: (context) => const ReservasPage(),
        paquetes: (context) => const PaquetesPage(),
        pagos: (context) => const PagosPage(),
        pqrs: (context) => const PqrsPage(),
        // Aquí puedes agregar más rutas cuando descomentes las páginas
        // '/pagos': (context) => const PagosPage(),
        // '/paquetes': (context) => const PaquetesPage(),
        // '/pqrs': (context) => const PqrsPage(),
      };

  // Manejo de rutas no encontradas
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) =>
          _ErrorPage(routeName: settings.name ?? 'Desconocida'),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final String routeName;

  const _ErrorPage({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Ruta: $routeName'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToHome(context),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}
