import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Screens/home.dart';
import 'package:recommendation_dsp/Screens/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';

class movieDet extends StatefulWidget {
  final String userId;
  final String filmID;
  final Map<dynamic, dynamic> filmData;

  movieDet({
    required this.userId,
    required this.filmID,
    required this.filmData,
  });

  @override
  movieDetState createState() => movieDetState();
}

class movieDetState extends State<movieDet> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  late Map<dynamic, dynamic> film;
  late String filmName;
  String liveRate = "Rate";
  late String userId;

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;

    setState(() {
      userId = widget.userId;
      film = widget.filmData;
      filmName = widget.filmData['title'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Film Details"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  filmName,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    film['overview'],
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Cast',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      for (var name in film['cast']) ...{
                        Text(
                          name['name'].toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      },
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
