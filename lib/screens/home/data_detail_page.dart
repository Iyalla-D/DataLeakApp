
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/services/database.dart';

class DataDetailPage extends StatelessWidget {
  final Data data;
  final useruid = FirebaseAuth.instance.currentUser!.uid;

  DataDetailPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Data>?>.value(
      value: DatabaseService(uid: useruid).userDataStream,
      initialData: null,
        child: Scaffold(
          appBar: AppBar(
            title: Text(data.name),
            actions: [
                TextButton(
                  onPressed: ()async{
                    
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
                Text('Password: ${data.password}'),
                Text('Data Leaked: ${data.isLeaked ? 'Yes' : 'No'}'),
              ],
            ),
          ),
        )
    );
  }
}
