import 'package:expense_record/screens/calendar_screen.dart';
import 'package:expense_record/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: WelcomeScreen(),
    );
  }
}