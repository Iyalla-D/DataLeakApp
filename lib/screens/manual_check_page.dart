import 'package:data_leak/models/data.dart';
import 'package:flutter/material.dart';


class CheckPwnedPage extends StatefulWidget {
  final List<Data>? data;
  final VoidCallback? onDataUpdate;

  CheckPwnedPage({this.data, this.onDataUpdate});
  
  @override
  _CheckPwnedPageState createState() => _CheckPwnedPageState();
}

class _CheckPwnedPageState extends State<CheckPwnedPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}