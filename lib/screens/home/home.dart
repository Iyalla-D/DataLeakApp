import 'package:data_leak/screens/home/data_entry.dart';
import 'package:data_leak/screens/home/data_list.dart';
import 'package:data_leak/screens/home/settings.dart';
import 'package:data_leak/screens/manual_check_page.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:data_leak/models/data.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Data> savedData = [];
  final useruid = AuthService().useruid;
  String searchQuery = '';
  bool isGridView = true;
  bool showSearchBar = false;
  final searchController = TextEditingController();


  void toggleGridView() {  
    setState(() {
      isGridView = !isGridView;
    });
  }

  void _getDataForCurrentUser() async {
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
          title: showSearchBar
              ? TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
                  ),
                )
              : const Text('Data Leak Detector'),
          actions: [
            IconButton(
              icon: Icon(showSearchBar ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  showSearchBar = !showSearchBar;
                  if (!showSearchBar) {
                    searchController.clear();
                    searchQuery = '';
                  }
                });
              },
            ),
          ],
        ),
        body: DataList(searchQuery: searchQuery, isGridView: isGridView),
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
                accountEmail: Text(FirebaseAuth.instance.currentUser!.email!),
                currentAccountPicture: const CircleAvatar(
                ), accountName: null,
              ),
              
              ListTile(
                leading: const Icon(Icons.view_module),  
                title: const Text('Toggle View'),
                onTap: () {
                  toggleGridView();  
                  Navigator.pop(context);  
                },
              ),

              ListTile(
                leading: const Icon(Icons.qr_code_scanner), 
                title: const Text('Scan'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckPwnedPage(),

                    ),
                  );
                },
              ),
              const SizedBox(height: 450),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(data: savedData,onDataUpdate: _getDataForCurrentUser,),
                    ),
                  );
                },

              ),
            ],
          ),
        ),

      ),
    );
  }
}
