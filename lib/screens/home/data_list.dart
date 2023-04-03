import 'package:data_leak/models/data.dart';
import 'package:data_leak/screens/home/data_detail_page.dart';
import 'package:data_leak/screens/home/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class DataList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _DataListState();

}

class _DataListState extends State<DataList>{
  

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<List<Data>?>(context);
    if (data != null) {
      data.forEach((data) {
        //print(data.email);
        //print(data.password);
       });
    }
    return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: data?.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final imageUrl = data != null && data.length > index ? data[index].url : '';
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataDetailPage(data: (data as List<Data>)[index])),
                );
              },
              onLongPress: (){
                  showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      data: (data as List<Data>)[index],
                    );
                  },
                );
              },
              //child image for the gridview builder
              child: imageUrl.isNotEmpty
                ? ClipOval(
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