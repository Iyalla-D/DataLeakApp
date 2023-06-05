// ignore_for_file: library_private_types_in_public_api

import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/screens/home/data_edit.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/services/database.dart';

class DataDetailPage extends StatefulWidget {
  final Data initialData;

  const DataDetailPage({super.key, required this.initialData});

  @override
  _DataDetailPageState createState() => _DataDetailPageState();
}

class _DataDetailPageState extends State<DataDetailPage> {
  late Data data;
  final useruid = AuthService().useruid;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    data = widget.initialData;
  }

  void _editData(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEditPage(
          data: data,
          onUpdate: (updatedData) {
            // Update the data in the current widget and refresh the UI
            setState(() {
              data = updatedData;
            });
          },
        ),
      ),
    );
  }

  Future<String> _getPassword() async {
    String encryptedPassword = data.password;
    String decryptedPassword = await PasswordApiService().decryptApiCall(encryptedPassword);
    return decryptedPassword;
  }

  Future<String> _getEmail() async {
    String encryptedEmail = data.email;
    String decryptedEmail = await PasswordApiService().decryptApiCall(encryptedEmail);
    return decryptedEmail;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : StreamProvider<List<Data>?>.value(
            value: DatabaseService(uid: useruid).userDataStream,
            initialData: null,
            child: Scaffold(
              appBar: AppBar(
                actions: const [
                  
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ListView(
                    children: [
                      
                      Text(
                        data.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.secondary), 
                      ),
                      
                      ListTile(
                        leading: Icon(Icons.link, color: Theme.of(context).primaryColor),
                        title: Text(data.url),
                        subtitle: const Text('URL'),
                      ),
                      FutureBuilder<String>(
                        future: _getEmail(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Loading...'),
                            );
                          } else if (snapshot.hasError) {
                            return ListTile(
                              leading: const Icon(Icons.error, color: Colors.red),
                              title: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            return ListTile(
                              leading: Icon(Icons.email, color: Theme.of(context).primaryColor),
                              title: Text('${snapshot.data}'),
                              subtitle: const Text('Email'),
                            );
                          }
                        },
                      ),
                      FutureBuilder<String>(
                        future: _getPassword(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Loading...'),
                            );
                          } else if (snapshot.hasError) {
                            return ListTile(
                              leading: const Icon(Icons.error, color: Colors.red),
                              title: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            return ListTile(
                              leading: Icon(Icons.vpn_key, color: Theme.of(context).primaryColor),
                              title: Text('${snapshot.data}'),
                              subtitle: const Text('Password'),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(data.isLeaked ? Icons.warning : Icons.check_circle, color: data.isLeaked ? Colors.red : Colors.green),
                        title: Text(data.isLeaked ? 'Yes' : 'No'),
                        subtitle: const Text('Data Leaked'),
                      ),



                      TextButton(
                        onPressed: () async {
                          _editData(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ), backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
