import 'package:expense_record/screens/expense_form_screen.dart';
import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      onDateChanged: (selectedDate) {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(date: selectedDate),
          ),
        );
      }
    );
  }
}