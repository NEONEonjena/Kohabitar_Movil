import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF1B6771),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1B6771),
      secondary: Color(0xFF30979A),
      background: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B6771),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'OpenSans',
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF30979A),
      foregroundColor: Colors.white,
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFFFFFFFF),
      elevation: 4,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B6771),
        fontFamily: 'OpenSans',
      ),
      
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),

      titleMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF00BFA5),
      ),
    ),

    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF30979A),
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF30979A)),
      ),
      labelStyle: TextStyle(color: Color(0xFF30979A)),
    ),
  );
  
 // 🌙 Tema oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF30979A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF30979A),
      secondary: Color(0xFF1B6771),
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B6771),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'OpenSans',
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF30979A),
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 4,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'OpenSans',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      
      titleMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF00BFA5),
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF30979A),
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF30979A)),
      ),
      labelStyle: TextStyle(color: Color(0xFF30979A)),
    ),
  );
}