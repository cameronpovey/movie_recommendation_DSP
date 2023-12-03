import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/amendRec.dart';
import 'package:recommendation_dsp/Functions/getRec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/star_rate.dart';

class BlankScreen extends StatefulWidget {
  @override
  _BlankScreenState createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  GetData connect = GetData();
  editRec feedback = editRec();
  late List<Map<dynamic, dynamic>> movies;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    movies = connect.getRecs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Movie Recommendations"),
      ),
      body: Column(
        children: [
          for (var movie in movies) ...[
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(movie['Name']),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(movie['Release']),
                                  ],
                                )
                              ],
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StarRatingModal(filmData: movie),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.stars),
                                  color: Colors.green,
                                )
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    feedback.bookmark(movie);
                                  },
                                  icon: Icon(Icons.bookmark_add_outlined),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    feedback.ignoreFilm(movie);
                                  },
                                  icon: const Icon(Icons.close),
                                  color: Colors.red,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ]
        ],
      ),
    );
  }
}
