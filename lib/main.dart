import 'package:flutter/material.dart';
// Importa el paquete base de Flutter para usar Material Design.
import 'pages/splash/splash_app.dart';
// Importa la pantalla de Splash, que será la primera en mostrarse al iniciar la app.
import 'theme/theme_app.dart';
// Importa el archivo donde definiste los temas claro y oscuro de la app.

import 'pages/main_page.dart';
import 'pages/zonas_comunes/zonas_comunes_page.dart';

// Un ValueNotifier es una clase que permite escuchar y reaccionar a cambios de un valor.
// En este caso, se usa para controlar el modo de tema (claro/oscuro).
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// La función principal de toda app Flutter.
// runApp() inicializa la aplicación y dibuja el widget raíz en la pantalla.
void main() {
  runApp(MyApp());
}

// Widget principal de la aplicación.
// Extiende de StatelessWidget porque no tiene estado propio, sino que depende de themeNotifier.
class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder reconstruye la interfaz cuando el valor de themeNotifier cambia.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // Escucha el valor actual del tema.
      builder: (context, mode, _) {
        // Cada vez que cambia el tema, se reconstruye el MaterialApp con el nuevo modo.
        return MaterialApp(
          title:
              'Flutter Demo App', // Nombre de la app (no visible en todos los dispositivos).

          // Tema claro de la app, definido en theme_app.dart
          theme: AppTheme.lightTheme,

          // Tema oscuro de la app, definido en theme_app.dart
          darkTheme: AppTheme.darkTheme,

          // Define qué tema usar: claro, oscuro o según el sistema.
          // Este valor lo controla themeNotifier.
          themeMode: mode,

          // Pantalla inicial de la aplicación (el SplashScreen).
          home: const SplashScreen(),

          routes: {
            '/main': (context) => MainPage(),
            '/zonas-comunes': (context) => ZonasComunesPage(),
          },

          // Quita la etiqueta roja de "DEBUG" en la esquina superior derecha.
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
