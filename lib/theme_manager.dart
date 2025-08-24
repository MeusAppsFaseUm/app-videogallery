import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _themeKey = 'selected_theme';

  // Lista de temas disponíveis
  static final Map<String, ThemeData> themes = {
    'Azul Original': ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    ),
    'Vermelho': ThemeData(
      primarySwatch: Colors.red,
      primaryColor: Colors.red,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.red),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness: Brightness.dark,
      ),
    ),
    'Preto': ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.dark,
      ),
    ),
    'Pink': ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: Colors.pink,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.pink),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pink,
        brightness: Brightness.dark,
      ),
    ),
    'Azul Escuro': ThemeData(
      primarySwatch: Colors.indigo,
      primaryColor: Colors.indigo,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.indigo),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
    ),
    'Laranja Escuro': ThemeData(
      primarySwatch: Colors.deepOrange,
      primaryColor: Colors.deepOrange,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.deepOrange),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
    ),
    'Verde Escuro': ThemeData(
      primarySwatch: Colors.green,
      primaryColor: Colors.green.shade800,
      appBarTheme: AppBarTheme(backgroundColor: Colors.green.shade800),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green.shade800,
        brightness: Brightness.dark,
      ),
    ),
    'Verde Folha': ThemeData(
      primarySwatch: Colors.lightGreen,
      primaryColor: Colors.lightGreen.shade700,
      appBarTheme: AppBarTheme(backgroundColor: Colors.lightGreen.shade700),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightGreen.shade700,
        brightness: Brightness.dark,
      ),
    ),
  };

  // Salvar tema selecionado
  static Future<void> saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
  }

  // Carregar tema salvo
  static Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'Azul Original';
  }

  // Obter cor primária do tema
  static Color getPrimaryColor(String themeName) {
    return themes[themeName]?.primaryColor ?? Colors.blue;
  }
}
