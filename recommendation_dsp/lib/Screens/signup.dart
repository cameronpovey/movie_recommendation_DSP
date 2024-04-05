import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import './welcome.dart';

class SignUpWelcome extends StatefulWidget {
  @override
  _SignUpWelcome createState() => _SignUpWelcome();
}

class _SignUpWelcome extends State<SignUpWelcome> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        centerTitle: true,
        //show a back button
        automaticallyImplyLeading: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlankScreenWelcome(),
              ),
            );
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Sign up to DSP Movie Recommendation',
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
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(hintText: "Password"),
                ),
                //
                Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () async {
                    UserCredential? cred =
                        await signup(email.text, password.text);
                    if (cred != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlankScreenWelcome(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Signup",
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

  Future<UserCredential?> signup(email, password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User registered successfully.');
      return cred;
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      return null;
    }
  }
}
