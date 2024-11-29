import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;

  CalendarWidget({
    required this.onMonthChanged,
    required this.onDateSelected
  });

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      onDateChanged: (selectedDate) {
        onMonthChanged(selectedDate);
        onDateSelected(selectedDate);
      },
      onDisplayedMonthChanged: (newMonth){
        onMonthChanged(newMonth);
      },
    );
  }
}