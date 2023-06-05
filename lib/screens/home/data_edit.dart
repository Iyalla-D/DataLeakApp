// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:data_leak/models/data.dart';
import 'package:data_leak/mutual/loading.dart';
import 'package:data_leak/screens/home/generate_pass_settings.dart';
import 'package:data_leak/services/auth.dart';
import 'package:data_leak/services/database.dart';
import 'package:data_leak/services/password_api.dart';
import 'package:flutter/material.dart';


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
  bool _passwordVisible = false;

  final useruid = AuthService().useruid;

  bool isPwned = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.data.name;
    _urlController.text = widget.data.url;
    _getDecryptedEmail();
    _getDecryptedPassword();
  }

  Future<void> _getDecryptedEmail() async {
    String decryptedEmail = await PasswordApiService().decryptApiCall(widget.data.email);
    setState(() {
      _emailController.text = decryptedEmail;
    });
  }

  Future<void> _getDecryptedPassword() async {
    String decryptedPassword = await PasswordApiService().decryptApiCall(widget.data.password);
    setState(() {
      _passwordController.text = decryptedPassword;
    });
  }

  Future<void> _generatePassword(int passwordLength) async {
    String newPassword = await PasswordApiService().generatePassword(passwordLength);
    print(newPassword);
    setState(() {
      _passwordController.text = newPassword;
    });
  }

  Future<void> _updateData() async {
    String encryptedEmail = await PasswordApiService().encryptApiCall(_emailController.text);
    String encryptedPassword = await PasswordApiService().encryptApiCall(_passwordController.text);
    isPwned = await PasswordApiService().pwndChecker(encryptedPassword);
    
    final updatedData = Data(
      id: widget.data.id,
      name: _nameController.text,
      url: _urlController.text,
      email: encryptedEmail,
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
  return loading
      ? const Loading()
      : Scaffold(
          appBar: AppBar(
            actions: [
              TextButton(
                onPressed: _handleGeneratePassword,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text('Generate Password'),
              ),
            ],
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
                          'Edit Data',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.secondary), 
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _urlController,
                          labelText: 'Url',
                          validator: _validateUrl,
                          prefixIcon: Icons.web,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          validator: _validateEmail,
                          prefixIcon: Icons.email,
                        ),
                        const SizedBox(height: 16.0),
                        _buildPasswordField(),
                        const SizedBox(height: 32.0),
                        _buildSubmitButton()
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
      style: const TextStyle(
        
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.primary) : null,
        labelStyle: const TextStyle(
          
          fontWeight: FontWeight.bold,
        ),
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
          validator: _validatePassword,
          prefixIcon: Icons.lock,
        ),
        IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _handleSubmit,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: const Text('Submit'),
    );
  }

  String? _validateUrl(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter a url for the data';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your password';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });

      await _updateData();

      setState(() {
        loading = false;
      });
    } else {
      print('Error validating form: data entry');
    }
  }

  void _handleGeneratePassword() async {
    int? newPasswordLength = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const GeneratePasswordSettings(),
        );
      },
    );

    if (newPasswordLength != null) {
      _generatePassword(newPasswordLength);
    }
  }
}
