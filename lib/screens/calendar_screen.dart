import 'package:expense_record/models/expense.dart';
import 'package:expense_record/screens/expense_form_screen.dart';
import 'package:expense_record/services/excel_handler.dart';
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
  double _generalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMonthlyTotal();
     _loadGeneralBalance();
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

  void _loadGeneralBalance() async {
    final balance = await FileStorage.loadGeneralBalance();
    setState(() {
      _generalBalance = balance;
    });
  }

  void _setGeneralBalance(double balance) async {
    final oldBalance = await FileStorage.loadGeneralBalance();
    if (oldBalance == 0) {
       setState(() {
        _generalBalance = balance;
      });
      FileStorage.saveGeneralBalance(balance);
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Para asignar un saldo debe estar en 0.0')),
        );
    }
   
  }

  void _showSetBalanceDialog() {
    final TextEditingController _balanceController = TextEditingController();
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Set general balance'),
          content: TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter balance'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final balance = double.tryParse(_balanceController.text) ?? 0.0;
                _setGeneralBalance(balance);
                Navigator.pop(context);
              },
              child: Text('Save')
              )
          ],
        );
      }
    );
  }

  void _onDateSelected(DateTime selectedDate) async {
    double balance = await FileStorage.loadGeneralBalance();
    if (_selectedDate.year == selectedDate.year) {
      if (balance > 0) {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(date: selectedDate),
          ),
        ).then((_) {
          _loadMonthlyTotal();
          _loadGeneralBalance();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient balance to add expenses.')),
        );
      }
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

  Future<void> _exportData() async {
    final expenses = await FileStorage.loadExpenses();
    if (expenses.isNotEmpty) {
        await ExcelHandler.exportToExcel(expenses, _generalBalance);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aún no hay gastos registrados.')),
      );
    }
    
  }

Future<void> _importData() async {
    final expenses = await FileStorage.loadExpenses();
    final balance = await FileStorage.loadGeneralBalance();

    if (expenses.isEmpty && balance == 0) {
       final result = await ExcelHandler.importFromExcel();
       final importedExpenses = result['expenses'] as List<Expense>;
       final importedBalance = result['balance'] as double;

       await FileStorage.saveExpenses(importedExpenses);
       await FileStorage.saveGeneralBalance(importedBalance);

       _loadMonthlyTotal();
       _loadGeneralBalance();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data imported successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Para importar data debe tener gastos y saldo en cero')),
      );
    }

   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportData,
          ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importData,
          ),
        ],
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
                ),
                SizedBox(height: 20),
                Text(
                  'General balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '\$${_generalBalance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 22, color: Colors.green),
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Set balance'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings'
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            _showSetBalanceDialog();
          } else if (index == 1) {
            // Lógica futura para configuraciones adicionales
            Navigator.pushNamed(context, '/settings');
          }
        }
      ),
    );
  }

}