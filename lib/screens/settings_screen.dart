import 'package:expense_record/services/file_storage.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode themeMode;

  SettingsScreen({
    required this.onThemeModeChanged, 
    required this.themeMode
  });

  Future<void> _resetData(BuildContext context) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restablecer valores a cero'),
          content: Text('¿Está seguro/a de restablecer los valores a cero de gastos y saldo general?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Restablecer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FileStorage.saveExpenses([]); 
      await FileStorage.saveGeneralBalance(0); 
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gastos y saldo restablecidos exitosamente.')),
      );
    }
  }

  Future<void> _addBalance(BuildContext context) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar saldo'),
          content: Text('¿Desea agregar más saldo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Agregar'),
            ),
          ],
        );
      }
    );

    if (confirmed == true) {
      final _balanceController = TextEditingController();
      showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar saldo'),
          content: TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Ingrese valor'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final balance = double.tryParse(_balanceController.text) ?? 0.0;
                _setGeneralBalance(balance, context);
                Navigator.pop(context);
              },
              child: Text('Guardar')
              )
          ],
        );
      }
    );
    }
  }

  void _setGeneralBalance(double balance, BuildContext context) async {
    final oldBalance = await FileStorage.loadGeneralBalance();
    
    if (oldBalance <= 0 ) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El saldo actual se encuentra en cero')),
      );
        
    } else {
      if (balance <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('El valor a agregar está en cero')),
          );
      } else {
        double total = oldBalance + balance;
        FileStorage.saveGeneralBalance(total);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se ha incrementado el saldo')),
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Modo claro/oscuro'),
            trailing: DropdownButton<ThemeMode>(
              underline: SizedBox.shrink(),
              value: themeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Claro'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Oscuro'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Por defecto del sistema'),
                ),
              ],
              onChanged: (newMode) {
                if (newMode != null) {
                  onThemeModeChanged(newMode);
                }
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Restablecer valores'),
            subtitle: Text('Limpiar todos los gastos y restablecer el saldo a cero'),
          ),
          // Agrega más opciones aquí
          ListTile(
            title: Text('Resetear'),
            subtitle: Text('Reiniciar a cero valores de gastos y saldo'),
            leading: Icon(Icons.refresh, color: Colors.red),
            onTap: () => _resetData(context),
          ),
          Divider(),
          ListTile(
            title: Text('Sumar al saldo'),
            subtitle: Text('Agregar al saldo actual más cantidad'),
            leading: Icon(Icons.add, color: Colors.green),
            onTap: () => _addBalance(context),
          ),
        ],
      ),
    );
  }
}
