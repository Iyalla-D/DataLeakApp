// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/database.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';
import 'package:uuid/uuid.dart';

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  DataEntryPageState createState() => DataEntryPageState();
}

class DataEntryPageState extends State<DataEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loading = false;
  final useruid = AuthService().useruid;
  bool isPwned = false;
  bool _passwordVisible = false;
 
  Future<void> _addNewData() async {
    String encryptedemail = await PasswordApiService().encryptApiCall(_emailController.text);
    print(encryptedemail);
    String encryptedPassword = await PasswordApiService().encryptApiCall(_passwordController.text);
    print(encryptedPassword);
    isPwned = await PasswordApiService().pwndChecker(encryptedPassword);

    final finalData = Data(
      id: const Uuid().v4(),
      name: _nameController.text,
      url: _urlController.text,
      email: encryptedemail,
      password: encryptedPassword,
      isLeaked: isPwned,
    );

    try {
      await DatabaseService(uid: useruid).addData(finalData);
      Navigator.pop(context, finalData);
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  String extractNameFromUrl(String url) {
  if (url.isEmpty) {
    return '';
  }

  final domain = url.split('.').first;
  final domainName = domain[0].toUpperCase() + domain.substring(1);
  print('Extracted domain name: $domainName');
  return domainName;
}

 @override
  Widget build(BuildContext context) {
    return loading
      ? const Loading()
      : Scaffold(
          appBar: AppBar(
           
          ),
          body: SafeArea( 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add New Data',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.secondary), 
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _urlController,
                          labelText: 'Url',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a url for the data';
                            }
                            return null;
                          },
                          prefixIcon: Icons.web,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email address';
                            }
                            return null;
                          },
                          prefixIcon: Icons.email,
                        ),
                        const SizedBox(height: 16.0),
                        _buildPasswordField(),
                        const SizedBox(height: 32.0),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.primary) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        _buildTextField(
          controller: _passwordController,
          labelText: 'Password',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your password';
            }
            return null;
          },
          prefixIcon: Icons.lock,
        ),
        IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async{
        if (_formKey.currentState?.validate() ?? false) {
          setState(() {
              loading = true;
          });

          await _addNewData();

          setState(() {
              loading = false;
          });
        } else {
          print('Error validating form: data entry');
        }
      },
      child: const Text('Submit'),
    );
  }
}