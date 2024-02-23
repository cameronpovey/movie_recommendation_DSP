import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/getRec.dart';

class ShowRatings extends StatefulWidget {
  //copy when passing
  final String userId;
  final Map<dynamic, dynamic> ratings;

  ShowRatings({
    required this.userId,
    required this.ratings,
  });

  @override
  _ShowRatingsState createState() => _ShowRatingsState();
}

class _ShowRatingsState extends State<ShowRatings> {
  GetData connect = GetData();
  Map<dynamic, dynamic> movies = {};
  late String userId;

  @override
  void initState() {
    super.initState;
    setState(() {
      userId = widget.userId;
      movies = widget.ratings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Past Ratings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            for (var movie in movies.keys) ...{
              Text("---------------------"),
              Text(movies[movie]['film_data']['title']),
              Text(movies[movie]['rating'].toString()),
              Text("---------------------"),
            }
          ],
        ),
      ),
    );
  }
}
