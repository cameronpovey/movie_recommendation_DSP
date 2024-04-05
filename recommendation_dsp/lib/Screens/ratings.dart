import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/getRec.dart';
import '../widgets/star_rate.dart';

class ShowRatings extends StatefulWidget {
  final String userId;
  final Map<dynamic, dynamic> ratings;
  final List<Map<dynamic, dynamic>> changes;

  ShowRatings({
    required this.userId,
    required this.ratings,
    required this.changes,
  });

  @override
  _ShowRatingsState createState() => _ShowRatingsState();
}

class _ShowRatingsState extends State<ShowRatings> {
  GetData connect = GetData();
  Map<dynamic, dynamic> movies = {};
  late String userId;
  late List<Map<dynamic, dynamic>> changes;
  Map<dynamic, dynamic> exportFilm = {};
  late int filmCoumt;

  @override
  void initState() {
    super.initState;
    userId = widget.userId;
    movies = widget.ratings;
    changes = widget.changes;

    filmCoumt = 0;
    // check if movie is in changes dict
    for (var movie in movies.keys) {
      if (movies[movie]['rating'] != 'bookmark') {
        filmCoumt++;
      }
      if (changes.any((element) => element['movie'] == movie)) {
        movies[movie]['changed'] = true;
      } else {
        movies[movie]['changed'] = false;
      }
    }

    setState(() {});
  }

  void reCount() {
    filmCoumt = 0;
    for (var movie in movies.keys) {
      if (movies[movie]['rating'] == 'bookmark') {
        filmCoumt++;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Past Ratings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pop({"movies": exportFilm, "changes": changes});
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (filmCoumt == 0) ...{
              const Center(
                child: Text(
                  "You have not rated any films yet",
                  style: TextStyle(fontSize: 20),
                ),
              )
            },
            for (var movie in movies.keys) ...{
              if (movies[movie]['rating'] != 'bookmark') ...{
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        movies[movie]['film_data']['title'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(
                        movies[movie]['rating'].toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.stars),
                            color: Colors.green,
                            onPressed: () async {
                              Map<dynamic, dynamic> filmData =
                                  movies[movie]['film_data'];
                              // rate film with StarRatingModal
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StarRatingModal(
                                    filmID: movie,
                                    filmData: filmData,
                                    userId: userId,
                                  ),
                                ),
                              );

                              if (result != null) {
                                changes.add(result);

                                movies[movie]['rating'] = result['rating'];

                                movies[movie]['changed'] = true;

                                reCount();

                                setState(() {});

                                //movies.remove(movie);
                                //editRec().rateFilm(movie, movies[movie], result['rating'], userId);
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () async {
                              if (movies[movie]['changed'] == true) {
                                changes.removeWhere(
                                    (element) => element['movie'] == movie);

                                Map<dynamic, dynamic> filmData =
                                    movies[movie]['film_data'];

                                exportFilm[movie] = {};
                                exportFilm[movie] = filmData;
                                exportFilm[movie]['changed'] = false;

                                //remove changes where movie is the same
                                changes.removeWhere(
                                    (element) => element['movie'] == movie);
                                movies.remove(movie);
                              } else {
                                changes.add({
                                  "movie": movie,
                                  "rating": 'remove',
                                  'data': movies[movie]['film_data']
                                });
                                movies.remove(movie);
                              }
                              reCount();
                              setState(() {});
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              },
            },
          ],
        ),
      ),
    );
  }
}
