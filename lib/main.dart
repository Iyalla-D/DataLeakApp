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

import 'services/database.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final useruid = AuthService().useruid;

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
        showNotification();
      }
    }

    // Return true when the task executed successfully or not
    return Future.value(true);
  });
}

Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'high_importance_channel', 'High Importance Notifications', 
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await flutterLocalNotificationsPlugin.show(
        0, 'Data leak detected', 'Your data has been leaked', platformChannelSpecifics,
        payload: 'This is your data leakage system');
}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
      "2",
      "checkForLeaks",
      frequency: const Duration(hours: 24),
  );
 
  // Notification plugin initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Define the notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  // Create the channel on the device.
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

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
        0xFF151E4E, 
        <int, Color>{
          50: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.1),
          100: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.2),
          200: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.3),
          300: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.4),
          400: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.5),
          500: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.6),
          600: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.7),
          700: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.8),
          800: const Color.fromARGB(30, 21, 78, 255).withOpacity(0.9),
          900: const Color.fromARGB(30, 21, 78, 255).withOpacity(1.0),
        },
      )
    ),
  );

  MainApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserObj?>.value(
      value: AuthService().user,
      initialData: UserObj(uid: 'nothing'),
      child: MaterialApp(
        title: 'My App',
        theme: myTheme,
        
        home: const Wrapper(),
        
      ),
    );
  }
}
