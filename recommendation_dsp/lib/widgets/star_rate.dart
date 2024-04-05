import 'package:flutter/material.dart';
import 'package:recommendation_dsp/Functions/amendRec.dart';

class StarRatingModal extends StatefulWidget {
  final String filmID;
  final Map<dynamic, dynamic> filmData;
  final String userId;

  StarRatingModal({
    required this.filmID,
    required this.filmData,
    required this.userId,
  });

  @override
  _StarRatingModalState createState() => _StarRatingModalState();
}

class _StarRatingModalState extends State<StarRatingModal> {
  int rating = 0;
  late Map<dynamic, dynamic> film;
  late String filmName;
  String liveRate = "Rate";
  late String userId;

  @override
  void initState() {
    debugPrint(widget.filmData.toString());
    super.initState();
    setState(() {
      userId = widget.userId;
      film = widget.filmData;
      filmName = widget.filmData['title'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 16;
    double starSize = screenWidth / 10;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("How did you like $filmName?"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      liveRate,
                      style: const TextStyle(
                          fontSize: 82, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: List.generate(
                10,
                (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                        liveRate = rating.toString();
                      });
                    },
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: starSize,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                //editRec().rateFilm(widget.filmID, widget.filmData, rating, userId);
                Navigator.of(context).pop(
                  {
                    "movie": widget.filmID,
                    "rating": rating,
                    'data': widget.filmData
                  },
                );
              },
              child: const Text("Submit Ratings →"),
            ),
          ),
          const SizedBox(
            height: 128,
          )
        ],
      ),
    );
  }
}
