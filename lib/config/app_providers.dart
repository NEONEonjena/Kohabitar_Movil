import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/providers/theme_provider.dart';
import '../pages/providers/auth_provider.dart';
import '../pages/providers/amenity_provider.dart';
import '../pages/providers/vehicle_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/amenity_repository.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositorios para acceso a datos
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => AmenityRepository()),

        // Proveedores de estado
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AmenityProvider(
            amenityRepository: context.read<AmenityRepository>(),
          ),
        ),

        // Proveedor de vehículos
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        
        // Proveedores comentados para futuras implementaciones
        // ChangeNotifierProvider(create: (_) => PropertyProvider()),
        // ChangeNotifierProvider(create: (_) => ParkingProvider()),
        // ChangeNotifierProvider(create: (_) => VisitorProvider()),
      ],
      child: child,
    );
  }
}
