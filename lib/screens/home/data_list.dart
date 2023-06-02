import 'dart:convert';

import 'package:data_leak/models/data.dart';
import 'package:data_leak/screens/home/data_detail_page.dart';
import 'package:data_leak/screens/home/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/models/userdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DataList extends StatefulWidget{
  final String searchQuery;
  
  DataList({required this.searchQuery});

  @override
  State<StatefulWidget> createState() => _DataListState();

}

const FlutterSecureStorage storage = FlutterSecureStorage();

class _DataListState extends State<DataList>{
  

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<List<Data>?>(context);
    
    Future<void> saveDataToSecureStorage(List<UserData> userDataList) async {
      String jsonUserDataList = jsonEncode(userDataList.map((data) => data.toJson()).toList());
      await storage.write(key: 'userDataList', value: jsonUserDataList);
    }

    if (data != null) {
      data.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      List<UserData> userDataList = data.map((item) => UserData(item.email, item.password)).toList();
      saveDataToSecureStorage(userDataList);
    }

    

    final filteredData = data
        ?.where((element) => element.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredData?.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final imageUrl = filteredData != null && filteredData.length > index ? filteredData[index].url : '';
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataDetailPage(initialData: (filteredData as List<Data>)[index])),
                );

              },
              onLongPress: (){
                  showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      data: (filteredData as List<Data>)[index],
                    );
                  },
                );
              },
              //child image for the gridview builder
              child: imageUrl.isNotEmpty
                ? ClipRRect(
                  //ClipOval
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.network(
                    'https://logo.clearbit.com/https://$imageUrl?size=799',
                    fit: BoxFit.cover,
                    ),
                )
              : const SizedBox.shrink(),
            );
            
          },
        );
  }

}