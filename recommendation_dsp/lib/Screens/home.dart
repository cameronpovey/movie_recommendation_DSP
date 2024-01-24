import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/amendRec.dart';
import 'package:recommendation_dsp/Functions/getRec.dart';
import 'package:recommendation_dsp/Screens/profile.dart';
import 'package:recommendation_dsp/Screens/ratings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/star_rate.dart';

class BlankScreen extends StatefulWidget {
  final String userId;

  BlankScreen({
    required this.userId,
  });

  @override
  _BlankScreenState createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  GetData connect = GetData();
  editRec feedback = editRec();
  Map<dynamic, dynamic> movies = {};
  late String userId;

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
    });

    fetchData();
  }

  fetchData() async {
    var response = await connect.getRecs(userId);
    setState(() {
      movies = response;
    });
    debugPrint(movies.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Movie Recommendations"),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowRatings(
                  userId: userId,
                ),
              ),
            );
            fetchData();
          },
          icon: Icon(Icons.star_border),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      userId: userId,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.person))
        ],
      ),
      body: ListView(
        children: [
          for (var movie in movies.keys) ...[
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          movies[movie]['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(DateTime.parse(
                                                movies[movie]['release_date'])
                                            .year
                                            .toString()),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StarRatingModal(
                                          filmID: movie,
                                          filmData: movies[movie],
                                          userId: userId,
                                        ),
                                      ),
                                    );
                                    fetchData;
                                    //REMOVE MOVIE
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
                                    feedback.bookmark(
                                        movie, movies[movie], userId);
                                    //REMOVE MOVIE
                                  },
                                  icon: Icon(Icons.bookmark_add_outlined),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    feedback.ignoreFilm(
                                        movie, movies[movie], userId);
                                    //REMOVE MOVIE
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
