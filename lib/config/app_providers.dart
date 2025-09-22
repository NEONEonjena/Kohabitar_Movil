import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/providers/theme_provider.dart';
import '../pages/providers/auth_provider.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Aquí puedes agregar más providers cuando los necesites
        // ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        // ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: child,
    );
  }
}
