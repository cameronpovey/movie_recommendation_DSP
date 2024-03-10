import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/amendRec.dart';
import 'package:recommendation_dsp/Functions/getRec.dart';
import 'package:recommendation_dsp/Screens/movie.dart';
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
  Map<dynamic, dynamic> ratings = {};
  late String userId;
  List<Map<dynamic, dynamic>> changes = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
    });

    fetchData();
    getRatings();
  }

  fetchData() async {
    var response = await connect.getRecs(userId);
    setState(() {
      movies = response;

      for (var movie in movies.keys) {
        movies[movie]['changes'] = false;
      }
    });
  }

  getRatings() async {
    var response = await connect.getRatings(userId);
    setState(() {
      ratings = response;
    });
  }

  pushNupdate() async {
    for (var changed in changes) {
      if (changed['rating'] == 'bookmark') {
        feedback.bookmark(changed['movie'], changed['data'], userId);
      } else if (changed['rating'] == 'ignore') {
        feedback.ignoreFilm(changed['movie'], changed['data'], userId);
      } else {
        feedback.rateFilm(
            changed['movie'], changed['data'], changed['rating'], userId);
      }
    }
    fetchData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Movie Recommendations"),
        leading: IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowRatings(
                  userId: userId,
                  ratings: ratings,
                ),
              ),
            );
            pushNupdate();
            // fetchData();
          },
          icon: Icon(Icons.star_border),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.push(
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
          if (changes.length > 0) ...{
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await pushNupdate();
                },
                child: Text('Update Recommendations'),
              ),
            ),
          },
          for (var movie in movies.keys) ...[
            if (movies[movie]['changed'] == true) ...[
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
                                            child: Text(movies[movie]['title']))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Rated " +
                                                ratings[movie]['rating']
                                                    .toString(),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      changes.remove(movie);

                                      ratings.remove(movie);

                                      movies[movie]['changed'] = false;

                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.undo),
                                    color: Colors.green,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => movieDet(
                                userId: userId,
                                filmID: movie,
                                filmData: movies[movie],
                              ),
                            ),
                          );
                        },
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
                                    onPressed: () async {
                                      var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StarRatingModal(
                                            filmID: movie,
                                            filmData: movies[movie],
                                            userId: userId,
                                          ),
                                        ),
                                      );

                                      if (result != null) {
                                        changes.add(result);

                                        ratings[movie] = {};
                                        ratings[movie]['film_data'] =
                                            movies[movie];
                                        ratings[movie]['rating'] =
                                            result['rating'];

                                        movies[movie]['changed'] = true;

                                        setState(() {});
                                        //movies.remove(movie);
                                        //editRec().rateFilm(movie, movies[movie], result['rating'], userId);
                                      }

                                      setState(() {});
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
                                      changes.add(
                                        {
                                          'movie': movie,
                                          'rating': 'bookmark',
                                          'data': movies[movie]
                                        },
                                      );
                                      ratings[movie] = {};
                                      ratings[movie]['film_data'] =
                                          movies[movie];
                                      ratings[movie]['rating'] = 'bookmark';

                                      movies[movie]['changed'] = true;
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.bookmark_add_outlined),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      changes.add(
                                        {
                                          'movie': movie,
                                          'rating': 'ignore',
                                          'data': movies[movie]
                                        },
                                      );
                                      ratings[movie] = {};
                                      ratings[movie]['film_data'] =
                                          movies[movie];
                                      ratings[movie]['rating'] = 'ignore';

                                      movies[movie]['changed'] = true;
                                      setState(() {});
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
            ],
          ]
        ],
      ),
    );
  }
}
