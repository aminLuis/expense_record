import 'package:expense_record/models/expense.dart';
import 'package:expense_record/services/file_storage.dart';
import 'package:expense_record/utils/expense_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<int, Map<int, Map<String, List<Expense>>>> _groupedExpenses = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await FileStorage.loadExpenses();
    setState(() {
      _groupedExpenses = groupByYearMonthAndCategory(expenses);
      _loading = false;
    });
  }

  String _getMonthName(int month) {
    return [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ][month - 1];
  }

  Widget _buildBarChart(Map<String, List<Expense>> categories) {
  // Contar categorías únicas
  Set<String> uniqueCategories = categories.keys.toSet();
  
  // Validación para mostrar el gráfico solo si hay al menos 4 categorías
  if (uniqueCategories.length < 4) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Se requieren al menos 4 categorías diferentes para mostrar el gráfico.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  try {
    final data = categories.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, e) => sum + e.amount);
      return _BarChartData(entry.key, total);
    }).toList();

    final chartWidth = data.length * 60.0;
    final maxAmount = data.isNotEmpty ? data.map((e) => e.amount).reduce((a, b) => a > b ? a : b) : 0.0;
    final chartHeight = maxAmount.clamp(300.0, 500.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(30.0),
        width: chartWidth,
        height: chartHeight,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    final interval = maxAmount / 5;
                    if (value % interval == 0 || value == maxAmount) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      final label = data[index].category.length > 10
                          ? data[index].category.substring(0, 10) + '...'
                          : data[index].category;
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(label, style: TextStyle(fontSize: 10)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              final index = entry.key;
              final barData = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: barData.amount,
                    color: Colors.blue,
                    width: 20,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  } catch (e) {
    return Center(
      child: Text(
        'Error al cargar el gráfico',
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Reporte de Gastos')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Reporte de Gastos')),
      body: ListView(
        children: _groupedExpenses.entries.map((yearEntry) {
          final year = yearEntry.key;
          final months = yearEntry.value;

          return ExpansionTile(
            title: Text('$year'),
            children: months.entries.map((monthEntry) {
              final month = monthEntry.key;
              final categories = monthEntry.value;

              return ExpansionTile(
                title: Text('${_getMonthName(month)}'),
                children: [
                  Container(
                    height: (categories.length * 50.0).clamp(300.0, 500.0),
                    child: _buildBarChart(categories),
                  ),
                  Divider(),
                  ...categories.entries.map((categoryEntry) {
                    final category = categoryEntry.key;
                    final expenses = categoryEntry.value;
                    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
                    return ListTile(
                      title: Text(category),
                      subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _BarChartData {
  final String category;
  final double amount;

  _BarChartData(this.category, this.amount);
}
