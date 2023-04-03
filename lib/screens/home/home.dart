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
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  List<Data> savedData = [];
  final useruid = AuthService().useruid;
   

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

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                //accountName: Text(FirebaseAuth.instance.currentUser!.displayName!),
                accountEmail: Text(FirebaseAuth.instance.currentUser!.email!),
                currentAccountPicture: const CircleAvatar(
                  // backgroundImage: NetworkImage(
                  //   FirebaseAuth.instance.currentUser!.photoURL!,
                  // ),
                ), accountName: null,
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 450),
              const Divider(),
              ListTile(
                title: const Text('Sign Out'),
                onTap: ()async{
                await _auth.signOut();
                },
              ),
            ],
          ),
        ),

        





      ),
    );
  }
}
