/// AuthWrapper
/// 
/// Este widget es responsable de decidir qué pantalla mostrar:
/// - Si el usuario está autenticado, muestra la página principal
/// - Si no está autenticado, muestra la pantalla de login
/// 
/// Funciona como un "guardián" que verifica el estado de autenticación
/// cada vez que la aplicación se inicia.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/providers/auth_provider.dart';
import '../pages/home/home.dart';
import '../pages/auth/login.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Variable que indica si se está cargando la información de autenticación
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Cuando el widget se inicializa, se verifica el estado de autenticación
    _checkAuthStatus();
  }

  // Función que espera un tiempo para permitir que el proveedor termine de cargar
  Future<void> _checkAuthStatus() async {
    // Se espera un breve momento para que el proveedor termine de cargar
    // Esto es necesario porque el proveedor podría estar realizando operaciones
    // asíncronas al inicializarse (como leer SharedPreferences)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Si el widget todavía está montado, se actualiza su estado
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si se está cargando, se muestra un indicador de progreso
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Verificando sesión...'),
            ],
          ),
        ),
      );
    }

    // Consumer escucha los cambios en el AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Se muestra información para depuración
        debugPrint('AuthWrapper - isLoggedIn: ${authProvider.isLoggedIn}');
        debugPrint('AuthWrapper - username: ${authProvider.username}');

        // DECISIÓN PRINCIPAL:
        // Si el usuario está autenticado y tiene un nombre de usuario, se dirige al Home
        if (authProvider.isLoggedIn && authProvider.username != null) {
          return const HomePage();
        }
        // Si no está autenticado, se dirige al Login
        else {
          return const LoginPage();
        }
      },
    );
  }
}