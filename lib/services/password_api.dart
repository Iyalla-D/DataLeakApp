import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PasswordApiService{
  final encryptApiUrl = 'http://https://dataleak-api.herokuapp.com/encrypt';
  final decryptApiUrl = 'http://dataleak-api.herokuapp.com/decrypt';
  final pwndPassCheckUrl = 'http://dataleak-api.herokuapp.com/ispasswordpwned';


  Future<String> encryptApiCall(String password) async {
    String encryptedPassword = "null";
    try{
      final response = await http.post(
        Uri.parse(encryptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'Obj': password,
          'master': 'my_master_password',
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

  Future<String> decryptApiCall(String password) async {
    try{
      final response = await http.post(
        Uri.parse(decryptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'Obj': password,
          'master': 'my_master_password',
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
    try{
      final response = await http.post(
        Uri.parse(pwndPassCheckUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'Obj': password,
          'master': 'my_master_password',
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



}