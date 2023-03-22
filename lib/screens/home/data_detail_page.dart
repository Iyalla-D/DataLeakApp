
import 'package:flutter/material.dart';
import 'package:data_leak/models/data.dart';

class DataDetailPage extends StatelessWidget {
  final Data data;

  DataDetailPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Url: ${data.url}'),
            Text('Email: ${data.email}'),
            Text('Password: ${data.password}'),
            Text('Data Leaked: ${data.isLeaked ? 'Yes' : 'No'}'),
          ],
        ),
      ),
    );
  }
}
