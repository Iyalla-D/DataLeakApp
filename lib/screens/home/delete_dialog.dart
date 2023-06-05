// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_leak/models/data.dart';
import 'package:data_leak/services/auth.dart';
import 'package:flutter/material.dart';

import '../../models/userdata.dart';
import 'data_list.dart';


class DeleteDialog extends StatelessWidget {
  final Data data;
  final useruid = AuthService().useruid;

  DeleteDialog({super.key, required this.data});

  Future<void> deleteDataFromSecureStorage(UserData userDataToDelete) async {
      // Read the current data from the storage
      String? jsonUserDataList = await storage.read(key: 'userDataList');

      // Decode the data
      List<UserData> userDataList = (jsonDecode(jsonUserDataList!) as List)
          .map((item) => UserData.fromJson(item))
          .toList();

      // Remove the data you want to delete
      userDataList.removeWhere((userData) => userData.id == userDataToDelete.id);

      // Encode and save the updated data list
      String updatedJsonUserDataList = jsonEncode(userDataList.map((data) => data.toJson()).toList());
      await storage.write(key: 'userDataList', value: updatedJsonUserDataList);
    }
    
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Data'),
      content: Text('Are you sure you want to delete ${data.name}?'),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('DELETE'),
          onPressed: () async {
            try{
              
              final dataCollection = FirebaseFirestore.instance.collection('data').doc(useruid).collection('user_data');
              final querySnapshot = await dataCollection
                  .where('id', isEqualTo: data.id)
                  .get();
              final docSnapshot = querySnapshot.docs.first;
              await docSnapshot.reference.delete();

              UserData userDataToDelete = UserData(data.id, data.email, data.password);
              deleteDataFromSecureStorage(userDataToDelete);

            }catch (e) {
              print('Error deleting document: $e');
            }
            
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}