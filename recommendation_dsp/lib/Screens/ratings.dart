import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/getRec.dart';

class ShowRatings extends StatefulWidget {
  //copy when passing
  final String userId;

  ShowRatings({
    required this.userId,
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
    });
    getRatings();
  }

  getRatings() async {
    var response = await connect.getRatings(userId);
    setState(() {
      movies = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Past Ratings"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var movie in movies.keys) ...{
            Text("---------------------"),
            Text(movies[movie]['film_data']['title']),
            Text(movies[movie]['rating'].toString()),
            Text("---------------------"),
          }
        ],
      ),
    );
  }
}
