import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ListTile(title: Text('Theme'), trailing: Text('Light')),
            ListTile(title: Text('Language'), trailing: Text('English')),
            ListTile(title: Text('Notifications'), trailing: Text('Enabled')),
          ],
        ),
      ),
    );
  }
}
