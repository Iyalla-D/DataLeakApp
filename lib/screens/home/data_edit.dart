import 'dart:convert';
import 'dart:io';

import 'package:data_leak/models/data.dart';
import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/database.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataEditPage extends StatefulWidget {
  final Data data;
  final Function(Data) onUpdate;

  const DataEditPage({required this.data, required this.onUpdate, Key? key})
      : super(key: key);

  @override
  DataEditPageState createState() => DataEditPageState();
}

class DataEditPageState extends State<DataEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loading = false;

  final useruid = AuthService().useruid;

  bool isPwned = false;
  String encryptedPassword = "null";

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.data.name;
    _urlController.text = widget.data.url;
    _emailController.text = widget.data.email;
    _passwordController.text = widget.data.password;
  }

  Future<void> _updateData() async {
    encryptedPassword = await PasswordApiService().encryptApiCall(_passwordController.text);
    isPwned = await PasswordApiService().pwndChecker(encryptedPassword);
    
    final updatedData = Data(
      name: _nameController.text,
      url: _urlController.text,
      email: _emailController.text,
      password: encryptedPassword,
      isLeaked: isPwned,
    );

    try {
      await DatabaseService(uid: useruid).updateData(updatedData);
      widget.onUpdate(updatedData);
      Navigator.pop(context);
    } catch (e) {
      print('Error updating data in Firestore: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return loading ? Loading(): Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a name for the data';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextFormField(
                controller: _urlController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a url for the data';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Url',
                ),
              ),
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
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState?.validate() ?? false) {
                    // setState(() {
                    //   loading = true;
                    // });

                    await _updateData();
                    
                    // setState(() {
                    //   loading = false;
                    // });
                  }
                  else{
                    print("error validating form: data entry");
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}