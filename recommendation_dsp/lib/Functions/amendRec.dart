import 'package:cloud_firestore/cloud_firestore.dart';

//used for view2db
class editRec {
  void ignoreFilm(film, data, userId) async {
    //add to db - ignored recommendation
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${userId}/Ratings/${film}');
    await newDoc.set({'rating': 'ignore'});
  }

  void bookmark(film, data, userId) async {
    //add to db - liked recommendation
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${userId}/Ratings/${film}');
    await newDoc.set({'rating': 'bookmark'});
  }

  void rateFilm(film, data, rating, userId) async {
    //add to db - rated recommendation
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${userId}/Ratings/${film}');
    await newDoc.set({'rating': rating});
  }

  void removeRating(film, userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference newDoc = firestore.doc('Users/${userId}/Ratings/${film}');
    await newDoc.delete();
  }
}
//have undo for a bit in home