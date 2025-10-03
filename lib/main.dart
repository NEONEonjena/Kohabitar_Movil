/// 
/// Este es el punto de entrada principal de la aplicación. Aquí se configuran
/// los proveedores de estado, el tema y las rutas de la aplicación.
/// 
/// La arquitectura se organiza en capas:
/// 
/// 1. Capa de UI (pages/): Pantallas y widgets con los que el usuario ve e interactúa
/// 2. Capa de Estado (providers/): Gestión del estado de la aplicación usando Provider
/// 3. Capa de Servicios (services/): Lógica de negocio y comunicación con el servidor
/// 4. Capa de Datos (models/): Estructuras de datos y conversión JSON
/// 
/// Esta versión está diseñada para ser fácil de entender y modificar.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Se importan los proveedores
import 'pages/providers/auth_provider.dart';
import 'pages/providers/theme_provider.dart';
import 'pages/providers/property_provider.dart';
import 'pages/providers/vehicle_provider.dart';
import 'pages/parqueaderos/providers/parking_slot_provider.dart';

// Se importan las páginas principales
import 'widgets/auth_wrapper.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';

// La función main es el punto de entrada de toda aplicación Dart
void main() {
  // Se inicia la aplicación Flutter
  runApp(const MyApp());
}

// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider permite proporcionar múltiples proveedores de estado a la vez
    return MultiProvider(
      providers: [
        // Provider para el tema (claro/oscuro)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Provider para la autenticación
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Provider para propiedades
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        
        // Provider para vehículos
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        
        // Provider para los espacios de parqueo
        ChangeNotifierProvider(create: (_) => ParkingSlotProvider()),
      ],
      // Consumer2 escucha los cambios en dos proveedores diferentes
      child: Consumer2<ThemeProvider, AuthProvider>(
        // El builder se ejecuta cada vez que ThemeProvider o AuthProvider cambian
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            // Título que aparece en el task switcher del dispositivo
            title: 'Kohabitar Móvil',
            
            // Configuración del tema
            theme: AppTheme.lightTheme,       // Tema claro
            darkTheme: AppTheme.darkTheme,    // Tema oscuro
            themeMode: themeProvider.themeMode, // Modo actual (sistema/claro/oscuro)
            
            // Página inicial (AuthWrapper decide si mostrar login o home)
            home: const AuthWrapper(),
            
            // Eliminar el banner de debug
            debugShowCheckedModeBanner: false,
            
            // Rutas para navegar entre páginas
            routes: AppRoutes.routes,
            
            // Qué hacer si se intenta navegar a una ruta no definida
            onUnknownRoute: AppRoutes.onUnknownRoute,
          );
        },
      ),
    );
  }
}

