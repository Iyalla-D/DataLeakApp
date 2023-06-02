import 'dart:convert';

import 'package:data_leak/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:data_leak/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/models/user.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:data_leak/models/userdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputdata) async {
    const storage = FlutterSecureStorage();

    // Retrieve and decode user data list
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

    // Return true when the task executed successfully or not
    return Future.value(true);
  });
}

void showNotification() async {
  var android = const AndroidNotificationDetails(
      'id', 'channel ', 
      priority: Priority.high, importance: Importance.max);
  
  var platform = NotificationDetails(android: android);
  await flutterLocalNotificationsPlugin.show(
      0, 'Data leak detected', 'Your data has been leaked', platform,
      payload: 'Welcome to your data leakage system');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //await AndroidAlarmManager.initialize();

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
      "2",
      "checkForLeaks",
      frequency: const Duration(hours: 1),
  );
  
  // Notification plugin initialization
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  
  var initSetttings = InitializationSettings(
      android: initializationSettingsAndroid,
      );

  await flutterLocalNotificationsPlugin.initialize(initSetttings);
  runApp(MainApp());
  
}

class MainApp extends StatelessWidget {
  final hexColor = 0xFF191825;

  final myTheme = ThemeData(
    fontFamily: 'Montserrat',
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF865DFF,
        <int, Color>{
          50: Color(0xFFF9F7FD),
          100: Color(0xFFF3EEFA),
          200: Color(0xFFE2D2FF),
          300: Color(0xFFD3B6FF),
          400: Color(0xFFC09AFF),
          500: Color(0xFF865DFF),
          600: Color(0xFF7A52E6),
          700: Color(0xFF6E49CC),
          800: Color(0xFF6240B3),
          900: Color(0xFF4B2E80),
        },
      ),
    ).copyWith(
      secondary: MaterialColor(
        0xFF191825,
        <int, Color>{
          50: const Color(0xFF191825).withOpacity(0.1),
          100: const Color(0xFF191825).withOpacity(0.2),
          200: const Color(0xFF191825).withOpacity(0.3),
          300: const Color(0xFF191825).withOpacity(0.4),
          400: const Color(0xFF191825).withOpacity(0.5),
          500: const Color(0xFF191825).withOpacity(0.6),
          600: const Color(0xFF191825).withOpacity(0.7),
          700: const Color(0xFF191825).withOpacity(0.8),
          800: const Color(0xFF191825).withOpacity(0.9),
          900: const Color(0xFF191825).withOpacity(1.0),
        },
      )
    ),
  );

  

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserObj?>.value(
      value: AuthService().user,
      initialData: UserObj(uid: 'nothing'),
      child: MaterialApp(
        title: 'My App',
        theme: myTheme,
        darkTheme: ThemeData.dark(),
        home: Wrapper(),
        
      ),
    );
  }
}
