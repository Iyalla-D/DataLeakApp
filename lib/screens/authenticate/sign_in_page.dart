// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/screens/authenticate/forgot_password.dart';
import 'package:data_leak/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/screens/authenticate/sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;
  
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return loading ? const Loading(): MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
       
      child: Scaffold(
        resizeToAvoidBottomInset : false,
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 50.0, bottom: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                const Text(
                    'Sign into your Account',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Log into your account',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email address';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if((value != null) && (value.length < 6)){
                       return 'Please enter a password with 6+ characters';
                    }
                    
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password'
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        loading = true;
                      });
                      dynamic result = await _auth.registerWithEmailAndPassword(_emailController.text,_passwordController.text);
                      print(result);
                      setState(() {
                          loading = false;
                        });
                      
                      
                    }
                  },
                  child: const Text('Sign In'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgottenPage()));
                  },
                  child: const Text('Forgot Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
