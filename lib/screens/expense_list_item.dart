import 'package:expense_record/models/expense.dart';
import 'package:expense_record/services/FormatNumber.dart';
import 'package:expense_record/services/Format_date.dart';
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
        '${FormatDate.fullDateFormat(expense.date)} - \$${Formatnumber.formatNumber(expense.amount)}\n${expense.category}',
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