import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class BlankScreenWelcome extends StatefulWidget {
  @override
  _BlankScreenStateW createState() => _BlankScreenStateW();
}

class _BlankScreenStateW extends State<BlankScreenWelcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: const Text(
            'Welcome to DSP Movie Recommendation',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
