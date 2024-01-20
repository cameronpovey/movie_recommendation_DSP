import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//used for view2db
class editRec {
  String User = 'User111';
  void ignoreFilm(film, data) async {
    //add to db - ignored recommendation
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${User}/Ratings/${film}');
    await newDoc.set({'rating': 'ignore'});
  }

  void bookmark(film, data) async {
    //add to db - liked recommendation
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${User}/Ratings/${film}');
    await newDoc.set({'rating': 'bookmark'});
  }

  void rateFilm(film, data, rating) async {
    //add to db - rated recommendation
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${User}/Ratings/${film}');
    await newDoc.set({'rating': rating});
  }
}
//have undo for a bit in home