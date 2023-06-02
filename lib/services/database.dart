import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_leak/models/data.dart';



class DatabaseService{

  final String uid;
  DatabaseService({ required this.uid});

  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('data');

  Future getSnapshot(){
    return dataCollection.doc(uid).collection('user_data').get();
  }
  
  Future addData(Data data) async {
    return await dataCollection.doc(uid).collection('user_data') // sub-collection 'user_data' within the user's document
    .doc().set({
      'id': data.id,
      'name': data.name,
      'url': data.url,
      'email': data.email,
      'password': data.password,
      'isLeaked': data.isLeaked,
    });
    
  }   

  Future updateData(Data data) async {
    final thisdataCollection = dataCollection.doc(uid).collection('user_data');
    final querySnapshot = await thisdataCollection
                  .where('id', isEqualTo: data.id)
                  .get();
    final docSnapshot = querySnapshot.docs.first;
    return await docSnapshot.reference.update({
      'id': data.id,
      'name': data.name,
      'url': data.url,
      'email': data.email,
      'password': data.password,
      'isLeaked': data.isLeaked,
    });             
  }

  Future initialUserData(String name,String url,String email,String password)async{
   return await dataCollection.doc(uid).collection('user_data') // sub-collection 'user_data' within the user's document
    .doc() // generate a new ID for the data
    .set({
      'id': "1",
      'name': name,
      'url': url,
      'email': email,
      'password': password,
      'isLeaked': false,
    });
  }

  List<Data> _dataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Data(
        id: (doc.data() as dynamic)['id'] ?? '',
        name: (doc.data() as dynamic)['name'] ?? '',
        url: (doc.data() as dynamic)['url'] ?? '',
        email: (doc.data() as dynamic)['email'] ?? '',
        password: (doc.data() as dynamic)['password'] ?? '',
        isLeaked: (doc.data() as dynamic)['isLeaked'] ?? '',
      );
    }).toList();
  }


  //get data Stream
  Stream<List<Data>> get userDataStream{
    return dataCollection.doc(uid).collection('user_data').snapshots()
      .map(_dataListFromSnapshot);
  }

}