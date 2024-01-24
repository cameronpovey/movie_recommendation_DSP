import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//db2view
class GetData {
  bool fakeData = false;
  bool local = false;
  bool useTestUser = false;

  Future<Map<dynamic, dynamic>> getRecs(userId) async {
    if (fakeData) {
      return GetfakeData();
    }

    Map<String, dynamic> jsonData = {};

    String testUser = 'User111';
    late http.Response response;

    if (local == true) {
      if (useTestUser == true) {
        response =
            await http.get(Uri.parse('http://192.168.1.120:8080/?id=User111'));
      } else {
        response = await http
            .get(Uri.parse('http://192.168.1.120:8080/?id=${testUser}'));
      }
      //local fake user
    } else {
      if (useTestUser == true) {
        response = await http.get(Uri.parse(
            'https://europe-west2-cohesive-memory-342803.cloudfunctions.net/function-1/?id=User111'));
      } else {
        //WHEN PASSING ACTUAL USER to FUNCTION
        response = await http.get(Uri.parse(
            'https://europe-west2-cohesive-memory-342803.cloudfunctions.net/function-1/?id=${userId}'));
      }
    }

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
    }

    return jsonData;
  }

  getRatings(userId) async {
    if (fakeData) {
      return GetfakeRateData();
    }

    Map<String, dynamic> jsonData = {};

    String testUser = 'User111';
    late http.Response response;

    if (local == true) {
      if (useTestUser == true) {
        response = await http
            .get(Uri.parse('http://192.168.1.120:8080/ratings/?id=User111'));
      } else {
        response = await http.get(
            Uri.parse('http://192.168.1.120:8080/ratings/?id=${testUser}'));
      }
    } else {
      if (useTestUser == true) {
        response = await http.get(Uri.parse(
            'https://europe-west2-cohesive-memory-342803.cloudfunctions.net/ratings/?id=User111'));
      } else {
        //WHEN PASSING ACTUAL USER to FUNCTION
        response = await http.get(Uri.parse(
            'https://europe-west2-cohesive-memory-342803.cloudfunctions.net/ratings/?id=${userId}'));
      }
    }

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
    }

    debugPrint(jsonData.toString());

    return jsonData;
  }
}

Map<String, dynamic> GetfakeData() {
  return {
    '-NoUZNS1FSGQcxEWIjGA': {
      'adult': false,
      'backdrop_path': '/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
      'genre_ids': [12, 18, 878],
      'genres': ['Adventure', 'Drama', 'Science Fiction'],
      'id': 157336,
      'original_language': 'en',
      'original_title': 'Interstellar',
      'overview':
          'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      'popularity': 158.113,
      'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'release_date': '2014-11-05',
      'title': 'Interstellar',
      'video': false,
      'vote_average': 8.4,
      'vote_count': 33394
    },
    '-NoUZNd9JfYR4tN-NxGd': {
      'adult': false,
      'backdrop_path': '/5Lbm0gpFDRAPIV1Cth6ln9iL1ou.jpg',
      'genre_ids': [18, 37],
      'genres': ['Drama', 'Western'],
      'id': 68718,
      'original_language': 'en',
      'original_title': 'Django Unchained',
      'overview':
          'With the help of a German bounty hunter, a freed slave sets out to rescue his wife from a brutal Mississippi plantation owner.',
      'popularity': 59.329,
      'poster_path': '/7oWY8VDWW7thTzWh3OKYRkWUlD5.jpg',
      'release_date': '2012-12-25',
      'title': 'Django Unchained',
      'video': false,
      'vote_average': 8.2,
      'vote_count': 25126
    },
    '-NoUZO_D1Oogu1Tv35Jl': {
      'adult': false,
      'backdrop_path': '/vUTVUdfbsY4DePCYzxxDMXKp6v6.jpg',
      'genre_ids': [16, 35, 10751],
      'genres': ['Animation', 'Comedy', 'Family'],
      'id': 585,
      'original_language': 'en',
      'original_title': 'Monsters, Inc.',
      'overview':
          "Lovable Sulley and his wisecracking sidekick Mike Wazowski are the top scare team at Monsters, Inc., the scream-processing factory in Monstropolis. When a little girl named Boo wanders into their world, it's the monsters who are scared silly, and it's up to Sulley and Mike to keep her out of sight and get her back home.",
      'popularity': 102.349,
      'poster_path': '/wFSpyMsp7H0ttERbxY7Trlv8xry.jpg',
      'release_date': '2001-11-01',
      'title': 'Monsters, Inc.',
      'video': false,
      'vote_average': 7.8,
      'vote_count': 17535
    }
  };
}

Map<String, dynamic> GetfakeRateData() {
  return {
    '-NoUZNS1FSGQcxEWIjGA': {
      'rating': 'bookmark',
      'film_data': {
        'adult': false,
        'backdrop_path': '/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
        'genre_ids': [12, 18, 878],
        'genres': ['Adventure', 'Drama', 'Science Fiction'],
        'id': 157336,
        'original_language': 'en',
        'original_title': 'Interstellar',
        'overview':
            'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
        'popularity': 158.113,
        'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        'release_date': '2014-11-05',
        'title': 'Interstellar',
        'video': false,
        'vote_average': 8.4,
        'vote_count': 33394
      }
    },
    '-NoUZNd9JfYR4tN-NxGd': {
      'rating': '9',
      'film_data': {
        'adult': false,
        'backdrop_path': '/5Lbm0gpFDRAPIV1Cth6ln9iL1ou.jpg',
        'genre_ids': [18, 37],
        'genres': ['Drama', 'Western'],
        'id': 68718,
        'original_language': 'en',
        'original_title': 'Django Unchained',
        'overview':
            'With the help of a German bounty hunter, a freed slave sets out to rescue his wife from a brutal Mississippi plantation owner.',
        'popularity': 59.329,
        'poster_path': '/7oWY8VDWW7thTzWh3OKYRkWUlD5.jpg',
        'release_date': '2012-12-25',
        'title': 'Django Unchained',
        'video': false,
        'vote_average': 8.2,
        'vote_count': 25126
      }
    },
    '-NoUZO_D1Oogu1Tv35Jl': {
      'rating': 'ignore',
      'film_data': {
        'adult': false,
        'backdrop_path': '/vUTVUdfbsY4DePCYzxxDMXKp6v6.jpg',
        'genre_ids': [16, 35, 10751],
        'genres': ['Animation', 'Comedy', 'Family'],
        'id': 585,
        'original_language': 'en',
        'original_title': 'Monsters, Inc.',
        'overview':
            "Lovable Sulley and his wisecracking sidekick Mike Wazowski are the top scare team at Monsters, Inc., the scream-processing factory in Monstropolis. When a little girl named Boo wanders into their world, it's the monsters who are scared silly, and it's up to Sulley and Mike to keep her out of sight and get her back home.",
        'popularity': 102.349,
        'poster_path': '/wFSpyMsp7H0ttERbxY7Trlv8xry.jpg',
        'release_date': '2001-11-01',
        'title': 'Monsters, Inc.',
        'video': false,
        'vote_average': 7.8,
        'vote_count': 17535
      }
    }
  };
}
