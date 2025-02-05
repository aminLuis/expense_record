import 'package:expense_record/models/expense.dart';
import 'package:expense_record/screens/expense_list_item.dart';
import 'package:expense_record/services/FormatNumber.dart';
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
  String? _selectedCategory;

  final List<String> _categories = [
  'Hogar',
  'Comida', 
  'Transporte', 
  'Mascota', 
  'Ocio', 
  'Servicio', 
  'Aseo', 
  'Aseo personal',
  'Producto de belleza',
  'Arriendo',
  'Crédito',
  'Vestimenta',
  'Diversión',
  'Medicamento',
  'Salón de belleza',
  'Barbería',
  'Combustible',
  'Refacciones vehículo',
  'Mantenimiento vehículo',
  'Seguro vehículo',
  'Tecnomecánica',
  'Impuesto vehicular',
  'Multa',
  'Viajes',
  'Inversión',
  'Otros'
  ];

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

    if (description.isEmpty || amount <= 0 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llene todos los campos y seleccione una categoría.')),
      );
      return;
    } 

    final newExpense = Expense(
      date: widget.date,
      description: description,
      amount: amount,
      category: _selectedCategory!
    );

    final expenses = await FileStorage.loadExpenses();
    final currentBalance = await FileStorage.loadGeneralBalance();

    if (currentBalance < amount) {
       ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Saldo insuficiente para agregar este gasto.')),
    );
    return;
    }

    expenses.add(newExpense);
    await FileStorage.saveExpenses(expenses);
    await FileStorage.saveGeneralBalance(currentBalance - amount);

    _descriptionController.clear();
    _amountController.clear();
     setState(() {
      _selectedCategory = null;
    });
    _loadDailyExpenses();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Gasto agregado exitosamente.')),
  );
  }    

  void _restoreBalance(double amount) async {
    final currentBalance = await FileStorage.loadGeneralBalance();
    double beforeBalance = currentBalance + amount;
    await FileStorage.saveGeneralBalance(beforeBalance);
  }

  void _subtractBalance(double amount) async {
    final currentBalance = await FileStorage.loadGeneralBalance();
    if (currentBalance >= amount) {
      double newBalance = currentBalance - amount;
      await FileStorage.saveGeneralBalance(newBalance);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Insufficient balance to add this expense.')),
      );
    }
  }

  void _editExpense(Expense expense) {
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();
    _selectedCategory = expense.category;
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
              ),
              DropdownButtonFormField(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              decoration: InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value as String?;
                });
              },
            ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                 _descriptionController.clear();
                _amountController.clear();
                 setState(() {
                  _selectedCategory = null;
                });
              },
              child: Text('Cancelar'),
              
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
                    e.amount == expense.amount &&
                    e.category == expense.category
                  );
                  if (index != -1) {
                    _restoreBalance(allExpenses[index].amount);
                    allExpenses[index] = Expense(
                      date: expense.date,
                      description: description,
                      amount: amount,
                      category: _selectedCategory.toString(),
                    );
                    await FileStorage.saveExpenses(allExpenses);
                    _subtractBalance(amount);
                    _loadDailyExpenses();
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Expense "${expense.description}" edit successfully!'),
                      duration: Duration(seconds: 3),
                    )
                  );
                  }
                }
                _descriptionController.clear();
                _amountController.clear();
                 setState(() {
                  _selectedCategory = null;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      }
    ); 
    FocusScope.of(context).unfocus();
  }

  void _deleteExpense(Expense expense) async {
    FocusScope.of(context).unfocus();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm deletetion'),
          content: Text('Are you sure want to delete this expense: "${expense.description}" with amount \$${expense.amount.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      }
    );

    if (shouldDelete == true) {
      final allExpenses = await FileStorage.loadExpenses();
      allExpenses.removeWhere((e) => 
        e.date == expense.date &&
        e.description == expense.description &&
        e.amount == expense.amount
      );
      _restoreBalance(expense.amount);
      FileStorage.saveExpenses(allExpenses);
      _loadDailyExpenses();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto "${expense.description}" eliminado exitosamente!'),
          duration: Duration(seconds: 3),
        )
      );
      
    }
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
            DropdownButtonFormField(
              value: _selectedCategory,
              items: _categories
                      .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                    .toList(),
              decoration: InputDecoration(labelText: 'Categoría'),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text('Guardar gasto'),
            ),
            Divider(height: 40),
            Text('Gastos diarios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _dailyExpenses.isEmpty
              ? Center(child: Text('No hay gastos en este día'))
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
              'Total: \$${Formatnumber.formatNumber(_totalDailyExpenses)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}