import 'package:expense_record/screens/settings_screen.dart';
import 'package:expense_record/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
    @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {

  ThemeMode _themeMode = ThemeMode.system; // Modo de tema inicial

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // Cargar modo seleccionado al iniciar la app
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 2; // 2: System default
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeMode.index);
  }

  void _updateThemeMode(ThemeMode themeMode) {
    print('Theme mode updated to: $themeMode');
    setState(() {
      _themeMode = themeMode;
    });
    _saveThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense tracker',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      routes: {
        '/': (context) => WelcomeScreen(
              themeMode: _themeMode, // Pasar el tema actual
              onThemeModeChanged: _updateThemeMode, // Pasar el método para cambiar tema
            ),
        '/settings': (context) =>
            SettingsScreen(onThemeModeChanged: _updateThemeMode, themeMode: _themeMode),
      },
    );
  }

}