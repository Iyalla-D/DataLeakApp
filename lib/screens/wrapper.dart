import 'package:data_leak/models/user.dart';
import 'package:data_leak/screens/home/home.dart';
import 'package:data_leak/screens/authenticate/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserObj>(context);
    
    if(user.uid == ' ' || user.uid == 'nothing'){
      return SignInPage();
    }
    else{
      return HomePage();
    }
    
  }

}