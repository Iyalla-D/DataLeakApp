import 'package:data_leak/screens/home/data_entry.dart';
import 'package:data_leak/screens/home/data_list.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:data_leak/models/data.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  List<Data> savedData = [];
  final useruid = FirebaseAuth.instance.currentUser!.uid;
   

  void _getDataForCurrentUser() async {
    
    if (useruid == null) {
      return;
    }

    final snapshot = await DatabaseService(uid: useruid).getSnapshot();
    final data = snapshot.docs.map<Data>((doc) => Data.fromJson(doc.data())).toList();

    setState(() {
      savedData = data;
    });
  }


  @override
  void initState() {
    super.initState();
    _getDataForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Data>?>.value(
      value: DatabaseService(uid: useruid).userDataStream,
      initialData: null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Data Leak Detector'),
          actions: [
            TextButton(
              onPressed: ()async{
                await _auth.signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
        body: DataList() ,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DataEntryPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
