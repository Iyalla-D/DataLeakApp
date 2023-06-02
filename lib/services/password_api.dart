import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordApiService{
  // final encryptApiUrl = 'https://dataleak-api.herokuapp.com/encrypt';
  // final decryptApiUrl = 'https://dataleak-api.herokuapp.com/decrypt';
  // final pwndPassCheckUrl = 'https://dataleak-api.herokuapp.com/ispasswordpwned';
  // final newPassword = 'https://dataleak-api.herokuapp.com/newPass';

  final encryptApiUrl = 'http://192.168.89.100:8080/encrypt';
  final decryptApiUrl = 'http://192.168.89.100:8080/decrypt';
  final pwndPassCheckUrl = 'http://192.168.89.100:8080/ispasswordpwned';
  final newPassword = 'http://192.168.89.100:8080/newPass';
  final findLeakUrl = 'http://192.168.89.100:8080/find-leaked-data';

  final storage = const FlutterSecureStorage();

  Future<String?> getMasterPassword() async {
    String? masterPassword = await storage.read(key: 'master_password');
    return masterPassword;
  }


  Future<String> encryptApiCall(String obj, [String? newMasterPassword]) async {
    String? masterPassword = await getMasterPassword();
    if (masterPassword == null) {
      masterPassword = await generatePassword(10);
      await storage.write(key: 'master_password', value: masterPassword);
    }

    // Use newMasterPassword if it's not null, otherwise use masterPassword
    String master = newMasterPassword ?? masterPassword;
    print(master);

    String encryptedPassword = "null";
    try{
      final response = await http.post(
        Uri.parse(encryptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'Obj': obj,
          'master': master ,
        }),
      );

      if(response.statusCode == 200){
        //print(response.body);
        encryptedPassword = response.body;
        return encryptedPassword;
      }

    }catch (e) {
      if (e is SocketException) {
        // Handle the case where the server is not available
        print('Server is not available: $e');
        return "";
      } 
      else {
        // Handle other exceptions
        print('Error occurred: $e');
        return "";
      }
    }
    return "";
  }

  Future<String> decryptApiCall(String obj) async {
    String? masterPassword = await getMasterPassword();
    
    if (masterPassword == null) {
      masterPassword = await generatePassword(10);
      await storage.write(key: 'master_password', value: masterPassword);
    }
    try{
      final response = await http.post(
        Uri.parse(decryptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'Obj': obj,
          'master': masterPassword ,
        }),
      );

      if(response.statusCode == 200){
        return response.body;
      }

    }catch (e) {
      if (e is SocketException) {
        // Handle the case where the server is not available
        print('Server is not available: $e');
      } 
      else {
        // Handle other exceptions
        print('Error occurred: $e');
      }
    }

    return "";
  }

  Future<bool> pwndChecker(String password) async {
    String? masterPassword = await getMasterPassword();
    if (masterPassword == null) {
      masterPassword = await generatePassword(10);
      await storage.write(key: 'master_password', value: masterPassword);
    }
    try{
      final response = await http.post(
        Uri.parse(pwndPassCheckUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'Obj': password,
          'master': masterPassword ,
        }),
      );

      if(response.statusCode == 200){
        print(response.body);
        return response.body.toLowerCase() == "true";
      }

    }catch (e) {
      if (e is SocketException) {
        // Handle the case where the server is not available
        print('Server is not available: $e');
      } 
      else {
        // Handle other exceptions
        print('Error occurred: $e');
      }
    }
    return false;
}


Future<String> generatePassword(int length) async {
  String generatedPassword = "null";
    try{
      final response = await http.get(
        Uri.parse('$newPassword?length=$length'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if(response.statusCode == 200){
        //print(response.body);
        generatedPassword = response.body;
        return generatedPassword;
      }

    }catch (e) {
      if (e is SocketException) {
        // Handle the case where the server is not available
        print('Server is not available: $e');
        return "";
      } 
      else {
        // Handle other exceptions
        print('Error occurred: $e');
        return "";
      }
    }
  return "";
}

Future<bool> findLeakCall(String email,String password) async {
    String? masterPassword = await getMasterPassword();
    
    if (masterPassword == null) {
      masterPassword = await generatePassword(10);
      await storage.write(key: 'master_password', value: masterPassword);
    }
    try{
      final response = await http.post(
        Uri.parse(findLeakUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'masspass': masterPassword,
          'pass': password,
        }),
      );

      if(response.statusCode == 200){
        return response.body.toLowerCase() == 'true';
      }

    }catch (e) {
      if (e is SocketException) {
        // Handle the case where the server is not available
        print('Server is not available: $e');
      } 
      else {
        // Handle other exceptions
        print('Error occurred: $e');
      }
    }
    return false;
  }


}