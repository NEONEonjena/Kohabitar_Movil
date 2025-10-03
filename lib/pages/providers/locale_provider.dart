import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor de Configuración Regional
/// 
/// Esta clase gestiona el idioma de la aplicación y persiste la selección
/// del usuario utilizando SharedPreferences.
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  SharedPreferences? _prefs;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // Carga la configuración regional guardada
  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs?.getString('language') ?? 'es';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Establece un nuevo idioma y lo guarda en preferencias
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('language', locale.languageCode);
    notifyListeners();
  }

  // Lista de idiomas soportados por la aplicación
  List<Locale> get supportedLocales => const [Locale('es'), Locale('en')];
}
