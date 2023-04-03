import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_leak/models/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DeleteDialog extends StatelessWidget {
  final Data data;
  final useruid = FirebaseAuth.instance.currentUser!.uid;

  DeleteDialog({required this.data});

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
                  .where('name', isEqualTo: data.name)
                  .get();
              final docSnapshot = querySnapshot.docs.first;
              await docSnapshot.reference.delete();


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