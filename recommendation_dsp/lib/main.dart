import 'package:flutter/material.dart';
import 'package:recommendation_dsp/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Screens/welcome.dart';
import 'Screens/home.dart';

Future<String> checkNew() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedValue = prefs.getString('userID');

  if (storedValue == null) {
    return 'nulluser';
  } else {
    return storedValue;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth _auth = FirebaseAuth.instance;

  late bool isNew;

  String userID = await checkNew();
  if (userID == 'nulluser') {
    isNew = true;
  } else {
    isNew = false;
  }

  //FOR TESTING
  //isNew = false;

  runApp(MyApp(isNew: isNew, userID: userID));
}

class MyApp extends StatelessWidget {
  final bool isNew;
  final String userID;
  MyApp({
    required this.isNew,
    required this.userID,
  });

  // This widget is the root of your application.
  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DSP RECOMMENDATIONS',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(
              0, 237, 237, 237), //keep transparency at 0 for appbar
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          bodySmall: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 10, 70, 80),
          onPrimary: Colors.black,
          secondary: Color.fromARGB(255, 66, 66, 66),
          onSecondary: const Color.fromARGB(255, 255, 255, 255),
          error: Colors.red,
          onError: Colors.white,
          background: const Color.fromARGB(255, 255, 255, 255),
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: isNew == true ? BlankScreenWelcome() : BlankScreen(userId: userID),
    );
  }
}
