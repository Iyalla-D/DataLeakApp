// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:data_leak/main.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/userdata.dart';
import '../services/auth.dart';
import '../services/database.dart';

class CheckPwnedPage extends StatefulWidget {
  const CheckPwnedPage({super.key});

  @override
  _CheckPwnedPageState createState() => _CheckPwnedPageState();
}


class _CheckPwnedPageState extends State<CheckPwnedPage> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const storage = FlutterSecureStorage();
  final useruid = AuthService().useruid;
  

  bool isLoading = false;

  Future<void> _checkPwned() async {
    try{
      setState(() {
        isLoading = true;
      });

      String? jsonUserDataList = await storage.read(key: 'userDataList');
      if (jsonUserDataList != null) {
        List<UserData> userDataList = (jsonDecode(jsonUserDataList) as List)
            .map((jsonUserData) => UserData.fromJson(jsonUserData))
            .toList();

        // Loop through each user data
        bool sendnoti=false;
        for (var userData in userDataList) {
          bool foundLeak =
              await PasswordApiService().findLeakCall(userData.email, userData.password);
          if (foundLeak) {
            sendnoti=true;
            await DatabaseService(uid: useruid).markAsLeaked(userData.id);
          }
        }
        if(sendnoti){
          print("noti");
          showNotification();
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: const Text('No leaks found'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                      label: 'DISMISS',
                      onPressed: () {
                      },
                  ),
              ),
          );
        }
      }

      setState(() {
        isLoading = false;
      });
    }on Exception catch(e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                  label: 'DISMISS',
                  onPressed: () {
                  },
              ),
          ),
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, 
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 16.0, 
              left: 16.0, 
              child: Material(
                  type: MaterialType.transparency,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: isLoading,
                      child: Container(
                        width: 0.8 * constraints.maxWidth,
                        height: 0.8 * constraints.maxWidth,
                        padding: const EdgeInsets.all(50.0),  // Value to change the size of the CircularProgressIndicator 
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, 
                        backgroundColor: Theme.of(context).colorScheme.primary, 
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(100), // Value to change the size of the Button 
                      ),
                      onPressed: !isLoading ? _checkPwned : null,
                      child: const Text('Scan'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }




}
