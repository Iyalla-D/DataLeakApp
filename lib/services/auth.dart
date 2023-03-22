import 'package:data_leak/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:data_leak/models/user.dart';

class AuthService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //User? get currentUser => _firebaseAuth.currentUser;

   
  UserObj _userFromFirebaseUser(User? user){
    return user != null ? UserObj(uid: user.uid) : UserObj(uid: ' ');
  }


  Stream<UserObj?>? get user {
    return _firebaseAuth.authStateChanges()
      .map((User? user)=> _userFromFirebaseUser(user));
  }

 
  //register with email and password
  Future registerWithEmailAndPassword(String email, String password)async{
    try{
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }catch (e) {
      print(e);
      return null;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      User? user = result.user;

      await DatabaseService(uid: user!.uid).initialUserData('dummyname','dummywebsite.com','dummy@dummy.com','dummy1234');
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }





  Future signOut() async {
    try{
      return await _firebaseAuth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
    
  }
  
}