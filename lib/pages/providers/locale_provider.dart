import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  SharedPreferences? _prefs;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs?.getString('language') ?? 'es';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('language', locale.languageCode);
    notifyListeners();
  }

  List<Locale> get supportedLocales => const [Locale('es'), Locale('en')];
}
