import 'package:expense_record/screens/calendar_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode themeMode;

  WelcomeScreen({
    required this.onThemeModeChanged,
    required this.themeMode,
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
                     onThemeModeChanged: onThemeModeChanged,
                     themeMode: themeMode,
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