import 'package:data_leak/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:data_leak/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/models/user.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        home: Wrapper(),
      ),
    );
  }
}
