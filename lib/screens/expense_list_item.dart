import 'package:expense_record/models/expense.dart';
import 'package:flutter/material.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  ExpenseListItem({
    required this.expense
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.description),
      subtitle: Text(
        '\$${expense.amount.toStringAsFixed(2)}',
        style: TextStyle(color: Colors.blueGrey),
      ),
    );
  }

}