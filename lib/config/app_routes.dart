import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/providers/auth_provider.dart';
import '../pages/splash/splash_app.dart';
import '../pages/auth/login.dart';
import '../pages/settings/settings_page.dart';
import '../pages/home/home.dart';
import '../pages/zonas_comunes/zonas_comunes_page.dart';
import '../pages/propiedades/property_list_screen.dart';
import '../pages/propiedades/property_detail_screen.dart';
import '../pages/users/users_page.dart';
import '../pages/parqueaderos/parqueaderos_page.dart';
import '../pages/parqueaderos/providers/parking_slot_provider.dart';
import '../pages/parqueaderos/widgets/parking_slot_list_screen.dart';
import '../pages/parqueaderos/widgets/api_tester.dart';
import '../pages/visitantes/visitantes_page.dart';
import '../pages/parking/parking_main_screen.dart';
import '../pages/parking/assign_vehicle_screen.dart';
import '../pages/parking/registered_vehicles_screen.dart';

class AppRoutes {
  // Constantes de definición de rutas
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String zonaComunes = '/zonas-comunes';
  static const String propiedades = '/propiedades';
  static const String propertyList = '/property-list';
  static const String propertyDetail = '/property-detail';
  static const String settings = '/settings';
  static const String usuarios = '/usuarios';
  static const String parqueaderos = '/parqueaderos';
  static const String parkingSlots = '/parking-slots';
  static const String apiTester = '/api-tester';
  static const String visitantes = '/visitantes';
  static const String parkingMain = '/parking-main';
  static const String assignVehicle = '/assign-vehicle';
  static const String registeredVehicles = '/registered-vehicles';

  // Mapeo de rutas a constructores de widgets
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashApp(),
        login: (context) => const LoginPage(),
        home: (context) => const HomePage(),
        zonaComunes: (context) => ZonasComunesPage(),
        settings: (context) => const SettingsPage(),
        propiedades: (context) => const PropertyListScreen(),
        propertyList: (context) => const PropertyListScreen(),
        propertyDetail: (context) {
          // Se obtiene la propiedad del argumento si está disponible
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final property = args?['property'];

          // Si no se proporciona propiedad, se redirecciona a la lista
          if (property == null) {
            print(
                'Advertencia: No se pasaron datos de propiedad a la ruta propertyDetail');
            return const PropertyListScreen();
          }

          return PropertyDetailScreen(property: property);
        },
        usuarios: (context) => const UsuariosPage(),
        parqueaderos: (context) => const ParqueaderosPage(),
        parkingSlots: (context) {
          // Se obtiene el zoneId del argumento si está disponible
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final zoneId = args?['zoneId'] as int?;

          return ChangeNotifierProvider(
            create: (_) => ParkingSlotProvider(),
            child: ParkingSlotListScreen(parkingZoneId: zoneId),
          );
        },
        apiTester: (context) {
          return ChangeNotifierProvider(
            create: (_) => ParkingSlotProvider(),
            child: const ApiTesterScreen(),
          );
        },
        visitantes: (context) => const VisitantesPage(),
        parkingMain: (context) => const ParkingMainScreen(),
        assignVehicle: (context) => const AssignVehicleScreen(),
        registeredVehicles: (context) => const RegisteredVehiclesScreen(),
        // '/pagos': (context) => const PagosPage(),
        // '/reportes': (context) => const ReportesPage(),
        // '/notificaciones': (context) => const NotificacionesPage(),
        // '/paquetes': (context) => const PaquetesPage(),
        // '/pqrs': (context) => const PqrsPage(),
      };

  // Función para el manejo de rutas no encontradas
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
