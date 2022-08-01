import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFav;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFav});

  void toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    final url = Uri.parse(
        'https://comixmanga-flutter-default-rtdb.firebaseio.com/userFav/$userId/$id.json?auth=$token');
    try {
      await http.put(
        url,
        body: json.encode(
          isFav,
        ),
      );
    } catch (error) {
      isFav = oldStatus;
      notifyListeners();
    }
  }
}
