import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(134, 93, 255, 1),
      child: const Center(
        child: SpinKitDoubleBounce(
          color: Color.fromRGBO(25, 24, 37, 1),
          size: 50,
        )
      ),
    );
  }

}