import 'dart:convert';
import 'dart:io';

import 'package:data_leak/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';
import 'package:http/http.dart' as http;

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPwned = false;
  final useruid = FirebaseAuth.instance.currentUser!.uid;
  final encryptApiUrl = 'http://192.168.84.100:8080/encrypt';
  final pwndPassCheckUrl = 'http://192.168.84.100:8080/ispasswordpwned';


  Future<void> _addNewData() async {

    final data = {
      'name': _nameController.text,
      'url': _urlController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'isLeaked': isPwned,
      'master': 'my_master_password',
    };

    //Encode the data as a JSON string
    final jsonData = json.encode(data);
    String encryptedPassword = "null";

    

    try{
      final response = await http.post(
        Uri.parse(encryptApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
      );

      if(response.statusCode == 200){
        encryptedPassword = response.body ;
      }

    }catch (e) {
      if (e is SocketException) {
        // Handle the case where the server is not available
        print('Server is not available: $e');
      } 
      else {
        // Handle other exceptions
        print('Error occurred: $e');
      }
    }

    final newData = Data(
        name: _nameController.text,
        url: _urlController.text,
        email: _emailController.text,
        password: encryptedPassword,
        isLeaked: isPwned,
      );




    try {
      await DatabaseService(uid: useruid).addData(newData);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, newData);
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Data'),
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
                
                    
                    await _addNewData();
                  }
                  else{
                    print("here");
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


