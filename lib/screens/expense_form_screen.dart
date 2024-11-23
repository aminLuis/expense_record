import 'package:expense_record/models/expense.dart';
import 'package:expense_record/screens/expense_list_item.dart';
import 'package:expense_record/services/file_storage.dart';
import 'package:flutter/material.dart';
import 'dart:core';

class ExpenseFormScreen extends StatefulWidget {
  final DateTime date;
  ExpenseFormScreen({
    required this.date
  });
  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  List<Expense> _dailyExpenses = [];
  double _totalDailyExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDailyExpenses();
  }

  void _loadDailyExpenses() async {
    final allExpenses = await FileStorage.loadExpenses();
    setState(() {
      _dailyExpenses = allExpenses
      .where((expense) =>
        expense.date.year == widget.date.year &&
        expense.date.month == widget.date.month &&
        expense.date.day == widget.date.day)
      .toList();
      _totalDailyExpenses = 
        _dailyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    });
  }

  void _saveExpense() async {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (description.isEmpty || amount <= 0) return;

    final newExpense = Expense(
      date: widget.date,
      description: description,
      amount: amount
    );

    final expenses = await FileStorage.loadExpenses();
    expenses.add(newExpense);
    await FileStorage.saveExpenses(expenses);

    _descriptionController.clear();
    _amountController.clear();
    _loadDailyExpenses();
  }    

  void _editExpense(Expense expense) {
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final description = _descriptionController.text;
                final amount = double.tryParse(_amountController.text) ?? 0.0;

                if (description.isNotEmpty && amount > 0) {
                  final allExpenses = await FileStorage.loadExpenses();
                  final index = allExpenses.indexWhere((e)=> 
                    e.date == expense.date &&
                    e.description == expense.description &&
                    e.amount == expense.amount
                  );
                  print('Index encontrado: ${index}');
                  if (index != -1) {
                    allExpenses[index] = Expense(
                      date: expense.date,
                      description: description,
                      amount: amount
                    );
                    await FileStorage.saveExpenses(allExpenses);
                    _loadDailyExpenses();
                  }
                }
                _descriptionController.clear();
                _amountController.clear();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      }
    ); 
  }

  void _deleteExpense(Expense expense) async {
  final allExpenses = await FileStorage.loadExpenses();
  allExpenses.removeWhere((e) => 
    e.date == expense.date &&
    e.description == expense.description &&
    e.amount == expense.amount);
    await FileStorage.saveExpenses(allExpenses);
    _loadDailyExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text('Save expense'),
            ),
            Divider(height: 40),
            Text('Daily expense',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _dailyExpenses.isEmpty
              ? Center(child: Text('No expenses for this day'))
              : ListView.builder(
                itemCount: _dailyExpenses.length,
                itemBuilder: (context, index) {
                  final expense = _dailyExpenses[index];
                  return ExpenseListItem(
                    expense: expense,
                    onEdit: () => _editExpense(expense),
                    onDelete: () => _deleteExpense(expense),
                  );
                }
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total: \$${_totalDailyExpenses.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}