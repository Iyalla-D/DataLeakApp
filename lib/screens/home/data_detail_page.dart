import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/screens/home/data_edit.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/services/database.dart';

class DataDetailPage extends StatelessWidget {
  Data data;
  final useruid = AuthService().useruid;
  bool loading = false;
  String decryptedPassword = "null";
  String encryptedPassword = "null";

  void _editData(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEditPage(
          data: data,
          onUpdate: (updatedData) {
            // Update the data in the current widget and refresh the UI
            data = updatedData;
            (context as Element).markNeedsBuild();
          },
        ),
      ),
    );
  }
  
  Future<String> _getPassword() async {
    encryptedPassword = data.password;
    decryptedPassword = await PasswordApiService().decryptApiCall(encryptedPassword);
    return decryptedPassword;
  }

  DataDetailPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return loading ? Loading(): StreamProvider<List<Data>?>.value(
      value: DatabaseService(uid: useruid).userDataStream,
      initialData: null,
        child: Scaffold(
          appBar: AppBar(
            title: Text(data.name),
            actions: [
                TextButton(
                  onPressed: ()async{
                    _editData(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Edit'),
                ),
              ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Url: ${data.url}'),
                Text('Email: ${data.email}'),
                FutureBuilder<String>(
                  future: _getPassword(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show a loading indicator while waiting for the password
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Show the error if any occurred
                    } else {
                      return Text('Password: ${snapshot.data}'); // Show the password when it's available
                    }
                  },
                ),
                Text('Data Leaked: ${data.isLeaked ? 'Yes' : 'No'}'),
              ],
            ),
          ),
        )
    );
  }
}
