import 'package:flutter/material.dart';

//db2view
class GetData {
  List<Map<dynamic, dynamic>> getRecs() {
    // call API for film recommendations

    return [
      {'Name': 'Film1', 'Release': '2011'},
      {'Name': 'Film20', 'Release': '2012'},
    ];
  }
}
