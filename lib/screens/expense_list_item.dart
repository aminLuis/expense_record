import 'package:expense_record/models/expense.dart';
import 'package:flutter/material.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  ExpenseListItem({
    required this.expense,
    required this.onDelete,
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.description),
      subtitle: Text(
        '${expense.date.toLocal().toString().split(' ')[0]} - \$${expense.amount.toStringAsFixed(2)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit'){
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
           PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          )
        ]
      )
    );
  }

}