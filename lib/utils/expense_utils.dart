import 'package:expense_record/models/expense.dart';

Map<int, Map<int, Map<String, List<Expense>>>> groupByYearMonthAndCategory(List<Expense> expenses) {
  Map<int, Map<int, Map<String, List<Expense>>>> groupedData = {};
  
  for (var expense in expenses) {
    final year = expense.date.year;
    final month = expense.date.month;
    final category = expense.category ?? 'Sin categoría';

    groupedData.putIfAbsent(year, () => {});
    groupedData[year]!.putIfAbsent(month, () => {});
    groupedData[year]![month]!.putIfAbsent(category, () => []);
    groupedData[year]![month]![category]!.add(expense);
  }
  
  return groupedData;
}
