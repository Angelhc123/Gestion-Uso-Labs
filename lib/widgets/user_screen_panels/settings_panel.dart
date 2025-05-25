import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(leading: Icon(Icons.notifications), title: Text('Notifications')),
        ListTile(leading: Icon(Icons.lock), title: Text('Privacy')),
        ListTile(leading: Icon(Icons.language), title: Text('Language')),
      ],
    );
  }
}
