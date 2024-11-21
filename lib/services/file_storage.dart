import 'dart:convert';
import 'dart:io';
import '../models/expense.dart';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/expenses.json');
  }

  static Future<List<Expense>> loadExpenses() async {
    try {
      final file = await _getFile();
      if (!file.existsSync()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final file = await _getFile();
    final contents = json.encode(expenses.map((e) => e.toJson()).toList());
    await file.writeAsString(contents);
  }

}