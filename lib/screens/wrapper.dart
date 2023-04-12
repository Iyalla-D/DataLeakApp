import 'package:data_leak/models/user.dart';
import 'package:data_leak/screens/authenticate/fingerprint_auth_page.dart';
import 'package:data_leak/screens/home/home.dart';
import 'package:data_leak/screens/authenticate/sign_in_page.dart';
import 'package:data_leak/services/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isAuthenticated = false;

  void _handleAuthentication() {
    setState(() {
      isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserObj>(context);

    if (user.uid == ' ' || user.uid == 'nothing') {
      return SignInPage();
    } else {
      return isAuthenticated
          ? HomePage()
          : FingerprintAuthPage(onAuthenticated: _handleAuthentication);
    }
  }
}
