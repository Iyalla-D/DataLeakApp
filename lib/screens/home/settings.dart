import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/services/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import this package

class SettingsPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final storage = const FlutterSecureStorage(); // Add this line

  Future<void> _showMasterPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Master Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Master Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String masterPassword = passwordController.text;
                // Save the master password to the local storage
                String encryptedPassword = await PasswordApiService().encryptApiCall(masterPassword);
                bool isPwned = await PasswordApiService().pwndChecker(encryptedPassword);
                if(!isPwned){
                  await storage.write(key: 'master_password', value: masterPassword);
                }
                
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Set Master Password'),
            onTap: () {
              _showMasterPasswordDialog(context);
            },
          ),
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
          
         
        ],
      ),
    );
  }
}
