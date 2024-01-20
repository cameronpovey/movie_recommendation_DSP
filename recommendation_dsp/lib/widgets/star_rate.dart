import 'package:flutter/material.dart';

class StarRatingModal extends StatefulWidget {
  final Map<dynamic, dynamic> filmData;

  StarRatingModal({
    required this.filmData,
  });

  @override
  _StarRatingModalState createState() => _StarRatingModalState();
}

class _StarRatingModalState extends State<StarRatingModal> {
  int rating = 0;
  late Map<dynamic, dynamic> film;
  late String filmName;
  String liveRate = "Rate";

  @override
  void initState() {
    debugPrint(widget.filmData.toString());
    super.initState();
    film = widget.filmData;
    filmName = widget.filmData['title'];
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
              onPressed: () {},
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
