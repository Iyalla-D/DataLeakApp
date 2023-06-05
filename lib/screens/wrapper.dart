// ignore_for_file: library_private_types_in_public_api

import 'package:data_leak/models/user.dart';
import 'package:data_leak/screens/authenticate/fingerprint_auth_page.dart';
import 'package:data_leak/screens/home/home.dart';
import 'package:data_leak/screens/authenticate/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

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
      return const SignInPage();
    } else {
      return isAuthenticated
          ? const HomePage()
          : FingerprintAuthPage(onAuthenticated: _handleAuthentication);
    }
  }
}
