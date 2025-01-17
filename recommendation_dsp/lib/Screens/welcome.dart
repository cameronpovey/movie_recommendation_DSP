import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Screens/home.dart';
import 'package:recommendation_dsp/Screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';

class BlankScreenWelcome extends StatefulWidget {
  @override
  _BlankScreenStateW createState() => _BlankScreenStateW();
}

class _BlankScreenStateW extends State<BlankScreenWelcome> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
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
                  //obscure text hides the password
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(hintText: "Password"),
                ),
                Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String? userId = await login(email.text, password.text);
                    debugPrint(userId.toString());

                    if (userId != null) {
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
                    "Login",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpWelcome(),
                      ),
                    );
                  },
                  child: Text(
                    "Sign Up ",
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

  Future<String?> login(email, password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in successfully.');
      return cred.user!.uid;
    } catch (e) {
      setState(() {
        error = e.toString().split('] ')[1];
      });
      return null;
    }
  }
}
