import 'package:expense_record/screens/settings_screen.dart';
import 'package:expense_record/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Expense tracker',
  //     theme: ThemeData(primarySwatch: Colors.green),
  //     home: WelcomeScreen(),
  //   );
  // }
    @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {

  ThemeMode _themeMode = ThemeMode.light; // Modo de tema inicial

  void _updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense tracker',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      routes: {
        '/': (context) => WelcomeScreen(),
        '/settings': (context) =>
            SettingsScreen(onThemeModeChanged: _updateThemeMode, themeMode: _themeMode),
      },
    );
  }

}