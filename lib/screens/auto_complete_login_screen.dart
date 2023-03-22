import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutocompleteLoginScreen extends StatefulWidget {
  const AutocompleteLoginScreen({Key? key}) : super(key: key);

  @override
  AutocompleteLoginScreenState createState() =>
      AutocompleteLoginScreenState();

  
}

class AutocompleteLoginScreenState extends State<AutocompleteLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _emails = [
    'john@example.com',
    'jane@example.com',
    'bob@example.com',
    'alice@example.com',
  ];

  final List<String> _passwords = [
    'password123',
    'password456',
    'qwerty',
    'letmein',
  ];

  String _selectedEmail = '';
  String _selectedPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email:',
              style: TextStyle(fontSize: 18.0),
            ),
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'john@example.com',
                ),
              ),
              suggestionsCallback: (String pattern) async {
                return _emails
                    .where((email) => email.startsWith(pattern))
                    .toList();
              },
              itemBuilder: (BuildContext context, String email) {
                return ListTile(
                  title: Text(email),
                );
              },
              onSuggestionSelected: (String email) {
                setState(() {
                  _emailController.text = email;
                  _selectedEmail = email;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Enter your password:',
              style: TextStyle(fontSize: 18.0),
            ),
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'password',
                ),
              ),
              suggestionsCallback: (String pattern) async {
                return _passwords
                    .where((password) => password.startsWith(pattern))
                    .toList();
              },
              itemBuilder: (BuildContext context, String password) {
                return ListTile(
                  title: Text(password),
                );
              },
              onSuggestionSelected: (String password) {
                setState(() {
                  _passwordController.text = password;
                  _selectedPassword = password;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Perform login with selected email and password
                // Here we just print them to the console
                print('Email: $_selectedEmail');
                print('Password: $_selectedPassword');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
