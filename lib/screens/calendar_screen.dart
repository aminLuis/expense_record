import 'package:expense_record/screens/expense_form_screen.dart';
import 'package:expense_record/services/file_storage.dart';
import 'package:expense_record/widgets/calendar_widget.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  double _monthlyTotal = 0.0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMonthlyTotal();
  }

  void _loadMonthlyTotal() async {
    final allExpenses = await FileStorage.loadExpenses();

    setState(() {
      _monthlyTotal = allExpenses
      .where((expense) =>
        expense.date.year == _selectedMonth.year &&
        expense.date.month == _selectedMonth.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    });
  }

  void _onDateSelected(DateTime selectedDate) {
    print('_selectedDate ${_selectedDate} < -- > selectedDate ${selectedDate}');
    if (_selectedDate.year == selectedDate.year) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseFormScreen(date: selectedDate),
        ),
      ).then((_) {
        _loadMonthlyTotal();
      });
    } else {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void _onMonthChanged(DateTime newDate) {
    setState(() {
      _selectedMonth = DateTime(newDate.year, newDate.month);
      _loadMonthlyTotal();
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding (
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total spent in ${_selectedMonth.month}/${_selectedMonth.year}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '\$${_monthlyTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 22, color: Colors.blue),
                )
              ],
            ),
          ),
          Expanded(
            child: CalendarWidget(
              onMonthChanged: _onMonthChanged,
              onDateSelected: _onDateSelected,
            ),
            )
        ],
      ),
    );
  }

}