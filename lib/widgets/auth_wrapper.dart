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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Esperar un poco para que el AuthProvider termine de cargar
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Debug prints (puedes removerlos en producción)
        debugPrint('AuthWrapper - isLoggedIn: ${authProvider.isLoggedIn}');
        debugPrint('AuthWrapper - username: ${authProvider.username}');

        // Si el usuario está autenticado, va al Home
        if (authProvider.isLoggedIn && authProvider.username != null) {
          return const HomePage();
        }
        // Si no está autenticado, va al Login
        else {
          return const LoginPage();
        }
      },
    );
  }
}
