import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode themeMode;

  SettingsScreen({
    required this.onThemeModeChanged, 
    required this.themeMode
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme Mode'),
            subtitle: Text('Select Light or Dark mode Select Light or Dark mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
              ],
              onChanged: (newMode) {
                if (newMode != null) {
                  onThemeModeChanged(newMode);
                }
              },
            ),
          ),
          // Agrega más opciones aquí
          ListTile(
            title: Text('Other Setting'),
            subtitle: Text('Additional functionality coming soon'),
          ),
        ],
      ),
    );
  }
}
