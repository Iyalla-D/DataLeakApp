// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class GeneratePasswordSettings extends StatefulWidget {
  const GeneratePasswordSettings({Key? key}) : super(key: key);

  @override
  _GeneratePasswordSettingsState createState() => _GeneratePasswordSettingsState();
}

class _GeneratePasswordSettingsState extends State<GeneratePasswordSettings> {
  double passwordLength = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Generate Password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Password Length: ${passwordLength.toInt()}'),
          Slider(
            value: passwordLength,
            min: 10,
            max: 40,
            divisions: 30,
            onChanged: (double value) {
              setState(() {
                passwordLength = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, passwordLength.toInt());
            },
            child: const Text('Generate Password'),
          ),
        ],
      ),
    );
  }
}
