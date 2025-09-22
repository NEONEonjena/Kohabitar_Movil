import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_providers.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'widgets/auth_wrapper.dart';
import 'pages/providers/theme_provider.dart';
import 'pages/providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: 'Administración Residencial',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,
            onUnknownRoute: AppRoutes.onUnknownRoute,
          );
        },
      ),
    );
  }
}
