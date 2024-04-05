import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Screens/welcome.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/star_rate.dart';

class Profile extends StatefulWidget {
  final String userId;
  final Map<dynamic, dynamic> movies;
  final List<Map<dynamic, dynamic>> changes;

  Profile({
    required this.userId,
    required this.movies,
    required this.changes,
  });

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  // get email from firebase
  String user = '';
  late Map<dynamic, dynamic> movies;
  late List<Map<dynamic, dynamic>> changes;
  Map<dynamic, dynamic> exportFilm = {};
  late int bookCount;

  FirebaseAuth _auth = FirebaseAuth.instance;

  late String userId;

  // function to get email from firebase with UID
  Future<String> getEmail() async {
    User? user = _auth.currentUser;
    return user!.email!;
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    movies = widget.movies;
    changes = widget.changes;
    bookCount = 0;

    // check if movie is in changes dict
    for (var movie in movies.keys) {
      if (movies[movie]['rating'] == 'bookmark') {
        bookCount++;
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
    bookCount = 0;
    for (var movie in movies.keys) {
      if (movies[movie]['rating'] == 'bookmark') {
        bookCount++;
      }
    }

    setState(() {});
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
                // Display the user's email
                FutureBuilder<String>(
                  future: getEmail(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(
                        snapshot.data.toString(),
                        style: TextStyle(fontSize: 15.0, color: Colors.grey),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(
                  height: 20,
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
                ),

                // DISPLAY BOOKMARKED MOVIES
                SizedBox(
                  height: 40,
                ),
                const Text(
                  'Bookmarks',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                //if movies with bookmark ratings dont exist
                if (bookCount == 0)
                  const Center(
                    child: Text(
                      "You have not bookmarked any movies yet",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),

                for (var movie in movies.keys) ...{
                  if (movies[movie]['rating'] == 'bookmark') ...{
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            movies[movie]['film_data']['title'],
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(
                            DateTime.parse(
                                    movies[movie]['film_data']['release_date'])
                                .year
                                .toString(),
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
                }
              ],
            ),
          ),
        ),
      ),
    );
  }
}
