import 'package:flutter/material.dart';
import 'package:data_leak/services/auth.dart';

class SettingsPage extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.red,
              ),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
              ),
            onTap: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}
