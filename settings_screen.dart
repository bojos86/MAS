import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(title: Text('Version'), subtitle: Text('Prototype 0.1.0')),
        ListTile(title: Text('Legal'), subtitle: Text('For demo only – no real banking.')),
      ],
    );
  }
}
