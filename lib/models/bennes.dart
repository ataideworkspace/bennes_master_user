import 'dart:async';
import 'dart:convert';
import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/url.dart';
import 'package:http/http.dart' as http;

Future<List<Bennes>> fetchBennes() async {
  final response = await http.get( urlClient() +
      pasta() + '/aplicacao/benne/get_bennes.php');
  if (response.statusCode == 200) {
    List _bennes = jsonDecode(response.body) as List;
    List<Bennes> bennes =
        _bennes.map((i) => Bennes.fromJson(i)).toList();
    return bennes;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load encomendas');
  }
}


class Bennes {
  final String number_;
  final String chauffeur;
  final String status_;
  final String camion;
  
  Bennes({
   this.camion,
   this.chauffeur,
   this.number_,
   this.status_,
  });

  factory Bennes.fromJson(Map<String, dynamic> json) {
    return Bennes(
      camion: json['camion'],
      chauffeur: json['chauffeur'],
      number_: json['number_'],
      status_: json['status_'],
    );
  }
}
