import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';

class BlankScreenWelcome extends StatefulWidget {
  @override
  _BlankScreenStateW createState() => _BlankScreenStateW();
}

class _BlankScreenStateW extends State<BlankScreenWelcome> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Welcome to DSP Movie Recommendation',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  controller: email,
                  decoration: InputDecoration(hintText: "Email"),
                ),
                TextField(
                  controller: password,
                  decoration: InputDecoration(hintText: "Password"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String userId = await login(email.text, password.text);
                    debugPrint(userId.toString());

                    if (userId != 'null') {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('userID', userId);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlankScreen(
                            userId: userId,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> login(email, password) async {
    try {
      try {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('User signed in successfully.');
        return cred.user!.uid;
      } catch (e) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('User registered successfully.');
        return cred.user!.uid;
      }
    } catch (e) {
      print('Error during sign-in: $e');
      return 'null';
    }
  }
}
