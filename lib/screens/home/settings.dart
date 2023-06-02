import 'package:data_leak/models/data.dart';
import 'package:data_leak/services/database.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/services/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatefulWidget {
  final List<Data>? data;
  final VoidCallback? onDataUpdate;

  SettingsPage({this.data, this.onDataUpdate});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _auth = AuthService();
  final storage = const FlutterSecureStorage();
  final useruid = AuthService().useruid;

  Future<void> _showMasterPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    String? oldMasterPassword = await storage.read(key: 'master_password');

    final data = widget.data;

    // ignore: use_build_context_synchronously
    return masterPassDialog(context, passwordController, oldMasterPassword ?? '', data);
  }

  Future<void> masterPassDialog(BuildContext context, TextEditingController passwordController, String oldMasterPassword, List<Data>? dataList) {
    String? errorMessage;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Enter Master Password'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Master Password'),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          errorMessage = null;
                        });
                      },
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red,fontSize: 12),
                        ),
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

                    // Checks if password has been pwned
                    String encryptedPassword = await PasswordApiService().encryptApiCall(masterPassword);
                    bool isPwned = await PasswordApiService().pwndChecker(encryptedPassword);

                    if (!isPwned && dataList != null) {
                      await reEncryptData(dataList, oldMasterPassword, masterPassword);
                      await storage.write(key: 'master_password', value: masterPassword);
                      Navigator.of(context).pop();
                    } else {
                      print("pwned");
                      setState(() {
                        errorMessage = 'Password not safe. Choose another.';
                      });
                    }

                    print(await storage.read(key: 'master_password'));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> reEncryptData(List<Data> dataList, String oldMasterPassword, String newMasterPassword) async {
    final passwordApiService = PasswordApiService();

    for (Data data in dataList) {
      print(data.name);
      // Decrypt email and password with the old master password
      String decryptedEmail = await passwordApiService.decryptApiCall(data.email);
      String decryptedPassword = await passwordApiService.decryptApiCall(data.password);

      // Encrypt email and password with the new master password
      String encryptedEmail = await passwordApiService.encryptApiCall(decryptedEmail, newMasterPassword);
      String encryptedPassword = await passwordApiService.encryptApiCall(decryptedPassword, newMasterPassword);

      // Update the data object with the newly encrypted email and password
      final updatedData = Data(
        id: data.id,
        name: data.name,
        url: data.url,
        email: encryptedEmail,
        password: encryptedPassword,
        isLeaked: data.isLeaked,
      );

      // Save the updated data object to the database
      await DatabaseService(uid: useruid).updateData(updatedData);
    }
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
