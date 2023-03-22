import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/screens/authenticate/sign_up_page.dart';

class SignInPage extends StatefulWidget {
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
    return loading ? Loading(): MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), 
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Sign In')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    if(mounted){
                      setState(() {
                        loading = false;
                      });
                    }
                    
                    
                  }
                },
                child: const Text('Sign In'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to forgot password page
                },
                child: const Text('Forgot Password'),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}
