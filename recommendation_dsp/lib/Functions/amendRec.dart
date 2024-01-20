import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//used for view2db
class editRec {
  void ignoreFilm(film, data) async {
    String User = 'User111';

    debugPrint(film);
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${User}/Ratings/${film}');
    await newDoc.set({'rating': 'ignore'});
  }

  void bookmark(film, data) {
    //add to db - liked recommendation
  }

  void rateFilm(film, data, rating) {
    //add to db - rated recommendation
  }
}
//have undo for a bit in home