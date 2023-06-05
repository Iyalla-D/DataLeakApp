import 'dart:convert';

import 'package:data_leak/models/data.dart';
import 'package:data_leak/screens/home/data_detail_page.dart';
import 'package:data_leak/screens/home/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_leak/models/userdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/password_api.dart';


class DataList extends StatefulWidget{
  final String searchQuery;
  final bool isGridView;
  
  const DataList({super.key, required this.searchQuery, required this.isGridView});

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

      List<UserData> userDataList = data.map((item) => UserData(item.id, item.email, item.password)).toList();
      saveDataToSecureStorage(userDataList);
    }

    final filteredData = data
        ?.where((element) => element.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    return widget.isGridView ?
     GridView.builder(
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
              child: imageUrl.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.network(
                    'https://logo.clearbit.com/https://$imageUrl?size=799',
                    fit: BoxFit.cover,
                    ),
                )
              : const SizedBox.shrink(),
            );
            
          },
        ): ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredData?.length,
          itemBuilder: (BuildContext context, int index) {
            final imageUrl = filteredData != null && filteredData.length > index ? filteredData[index].url : '';
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataDetailPage(initialData: (filteredData as List<Data>)[index])),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      data: (filteredData as List<Data>)[index],
                    );
                  },
                );
              },
              leading: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.network(
                      'https://logo.clearbit.com/https://$imageUrl?size=799',
                      fit: BoxFit.cover,
                    ),
                  )
                : const SizedBox.shrink(),
              title: Text(filteredData?[index].name ?? ''),
              subtitle: FutureBuilder<String>(
                future: filteredData?[index].email != null
                    ? PasswordApiService().decryptApiCall(filteredData![index].email)
                    : Future.value(''),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data ?? '');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const Text('Loading...');
                },
              ),
            );
          },
        );
        
  }

}