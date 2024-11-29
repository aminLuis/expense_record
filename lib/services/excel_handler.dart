import 'dart:io';

import 'package:excel/excel.dart';
import 'package:expense_record/models/expense.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

class ExcelHandler {

  static Future<void> exportToExcel(List expenses, double balance) async {
    try {
      final excel = Excel.createExcel();

      // Hoja de gastos
      final sheet = excel['Expenses'];
      sheet.appendRow(['Date', 'Description', 'Amount']);
      for (var expense in expenses) {
        sheet.appendRow([expense.date.toString(), expense.description, expense.amount]);
      }

      // Hoja de saldo
      final balanceSheet = excel['Balance'];
      balanceSheet.appendRow(['General Balance']);
      balanceSheet.appendRow([balance]);

      // Guardar en carpeta Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final filePath = p.join(directory.path, 'expenses_balance.xlsx');
      final file = File(filePath);
      file.writeAsBytesSync(excel.save()!);

      // Abrir archivo después de exportar
      OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Error exporting Excel file: $e');
    }
  }

  static Future<Map<String, dynamic>> importFromExcel() async {
  try {
    // Seleccionar archivo Excel
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'], 
    );

    if (result != null && result.files.single.path != null) {
      // Leer el archivo seleccionado
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Inicializar listas para almacenar datos
      List<Expense> expenses = [];
      double balance = 0.0;

      // Leer hoja de gastos ('Expenses')
      var expensesSheet = excel['Expenses'];
      if (expensesSheet != null) {
        for (int i = 1; i < expensesSheet.rows.length; i++) {
          var row = expensesSheet.rows[i];

          // Validar valores de las celdas
          var date = DateTime.tryParse(row[0]?.value?.toString() ?? '');
          var description = row[1]?.value?.toString() ?? '';
          var amount = double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0;

          if (date != null && description.isNotEmpty) {
            expenses.add(Expense(date: date, description: description, amount: amount));
          }
        }
      }

      // Leer hoja de balance ('Balance')
      var balanceSheet = excel['Balance'];
      if (balanceSheet != null && balanceSheet.rows.length > 1) {
        balance = double.tryParse(balanceSheet.rows[1][0]?.value?.toString() ?? '0') ?? 0.0;
      }

      return {'expenses': expenses, 'balance': balance};
    }
  } catch (e) {
    print('Error importing Excel file: $e');
  }

  // Retorno por defecto en caso de error
  return {'expenses': [], 'balance': 0.0};
}

}