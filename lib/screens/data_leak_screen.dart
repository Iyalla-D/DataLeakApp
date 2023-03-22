import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataLeakApp extends StatelessWidget {
  const DataLeakApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Leak Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DataLeakHomePage(key: Key('DataLeakHomePage')),
    );
  }
}





class DataLeakHomePage extends StatefulWidget {
  const DataLeakHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DataLeakHomePageState createState() => _DataLeakHomePageState();
}

class _DataLeakHomePageState extends State<DataLeakHomePage> {
  // Define variables and state for the app here
   final passwordController = TextEditingController();
   bool isLeaked = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Leak Checker'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Check if your password has been leaked:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border:  OutlineInputBorder(),
                  labelText: 'Enter your password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async{
                  // Implement the logic for checking if the password has been leaked
                  final password = passwordController.text;
                  


                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a password.'))
                    );
                  } else{
                      print(password);
                      final apiUrl = 'http://localhost:8080/ispasswordpwned?password=$password';
                    
                      final response = await http.get(Uri.parse(apiUrl));
                      

                      if(response.statusCode == 200 && response.body=="true"){
                        print("True");
                        setState(() {
                        // Update the UI to display the result
                          _resultText = const Text(
                          'True',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                        });
                        
                      
                      }
                      else{
                        print("False");
                        setState(() {
                          // Update the UI to display the result
                            _resultText = const Text(
                            'False',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }); 
                      }

                      const apiUrl2 = 'http://localhost:8080/encrypt';

                      final data = {
                        'password': password,
                        'master': 'my_master_password',
                      };

                      // Encode the data as a JSON string
                      final jsonData = json.encode(data);
                      
                      final response2 = await http.post(
                        Uri.parse(apiUrl2),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonData,
                      );

                        if(response2.statusCode == 200){
                          final encryptedPassword = response2.body;
                          print(encryptedPassword);
                          setState(() {
                            // Update the UI to display the result
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Encrypted Password: $encryptedPassword'))
                          );
                          
                          });
                        }else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to encrypt password.'))
                          );
                        }





                    }
        
                },
                child: const Text('Check'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Is Password Leaked? ',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: _resultText ?? const Text('No leaked passwords found.'),
            ),
          ],
        ),
      ),
    );
  }
}

// Define a variable to hold the result text widget
  Widget? _resultText;