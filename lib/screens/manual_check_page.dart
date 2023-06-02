import 'dart:convert';

import 'package:data_leak/main.dart';
import 'package:data_leak/models/data.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/userdata.dart';
import '../services/auth.dart';
import '../services/database.dart';


class CheckPwnedPage extends StatefulWidget {
  final List<Data>? data;
  final VoidCallback? onDataUpdate;

  CheckPwnedPage({this.data, this.onDataUpdate});
  
  @override
  _CheckPwnedPageState createState() => _CheckPwnedPageState();
}

class _CheckPwnedPageState extends State<CheckPwnedPage> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const storage = FlutterSecureStorage();
  final useruid = AuthService().useruid;

  Future<void> _checkPwned() async {
    String? jsonUserDataList = await storage.read(key: 'userDataList');
    if (jsonUserDataList != null) {
      List<UserData> userDataList = (jsonDecode(jsonUserDataList) as List)
          .map((jsonUserData) => UserData.fromJson(jsonUserData))
          .toList();

      // Loop through each user data
      for (var userData in userDataList) {
        bool foundLeak =
            await PasswordApiService().findLeakCall(userData.email, userData.password);
        if (foundLeak) {
          showNotification();
          break;
        }
      }
    }
  }

  Future<void> reCheckIfLeaked(List<Data> dataList, String newMasterPassword) async {

    for (Data data in dataList) {

      final updatedData = Data(
        id: data.id,
        name: data.name,
        url: data.url,
        email: data.email,
        password: data.password,
        isLeaked: data.isLeaked,
      );
      await DatabaseService(uid: useruid).updateData(updatedData);
    }
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check if Password is Pwned'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _checkPwned,
              child: const Text('Check if Pwned'),
            ),
            const SizedBox(height: 16.0),
        
          ],
        ),
      ),
    );
  }
}