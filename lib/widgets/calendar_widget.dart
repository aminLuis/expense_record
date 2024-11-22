import 'package:expense_record/screens/expense_form_screen.dart';
import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      onDateChanged: (selectedDate) {
        if (_selectedDate.year == selectedDate.year) {
              Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ExpenseFormScreen(date: selectedDate)
              )
            );
        } else {
          setState(() {
            _selectedDate = selectedDate;
          });
        }
      }
    );
  }
}