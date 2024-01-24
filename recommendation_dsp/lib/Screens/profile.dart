import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Screens/home.dart';
import 'package:recommendation_dsp/Screens/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';

class Profile extends StatefulWidget {
  final String userId;

  Profile({
    required this.userId,
  });

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlankScreenWelcome(),
                      ),
                    );
                  },
                  child: Text("Logout"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
