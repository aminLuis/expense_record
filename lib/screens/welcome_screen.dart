import 'package:expense_record/screens/calendar_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
   final ThemeMode themeMode;
  final Function(ThemeMode) onThemeModeChanged;

  WelcomeScreen({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Expense tracker',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Track your daily, monthly, and yearly expenses easily.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => CalendarScreen(
                     themeMode: themeMode, // Pasar el tema actual
                     onThemeModeChanged: onThemeModeChanged,
                  )),
                );
              },
              child: Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}