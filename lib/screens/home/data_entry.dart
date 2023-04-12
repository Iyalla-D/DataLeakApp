import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/database.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';

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

  //String Domain = "";
  bool loading = false;

  final useruid = AuthService().useruid;

  bool isPwned = false;
 

  Future<void> _addNewData() async {
    String encryptedemail = await PasswordApiService().encryptApiCall(_emailController.text);
    print(encryptedemail);
    String encryptedPassword = await PasswordApiService().encryptApiCall(_passwordController.text);
    print(encryptedPassword);
    isPwned = await PasswordApiService().pwndChecker(encryptedPassword);

    final finalData = Data(
        name: _nameController.text,
        url: _urlController.text,
        email: encryptedemail,
        password: encryptedPassword,
        isLeaked: isPwned,
      );

    try {
      await DatabaseService(uid: useruid).addData(finalData);
      // ignore: use_build_context_synchronously
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
    return loading ? Loading(): Scaffold(
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
                onChanged: (value) {
                  _nameController.text = extractNameFromUrl(_urlController.text);
                  print(_nameController.text);
                },
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
                    setState(() {
                        loading = true;
                      });

                    await _addNewData();
                    
                    setState(() {
                        loading = false;
                      });
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