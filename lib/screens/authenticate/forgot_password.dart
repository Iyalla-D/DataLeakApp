// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/services/auth.dart';
import 'package:flutter/material.dart';

class ForgottenPage extends StatefulWidget {
  const ForgottenPage({super.key});

  @override
  _ForgottenPageState createState() => _ForgottenPageState();
}

class _ForgottenPageState extends State<ForgottenPage>{
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;
  

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading(): Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
              const SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await _auth.resetPassword(_emailController.text);
                    print(result);
                    if(result!=null){
                      Navigator.of(context).pop();
                    }
                    setState(() {
                        loading = false;
                      });
                  }
                },
                child: const Text('Recover Password'),
              ),

            ],
          ),
        ),
      ),
    );
  }


}