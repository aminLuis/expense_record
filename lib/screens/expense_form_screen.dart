import 'package:expense_record/models/expense.dart';
import 'package:expense_record/services/file_storage.dart';
import 'package:flutter/material.dart';

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

    Navigator.pop(context);
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
          ],
        ),
      ),
    );
  }
}