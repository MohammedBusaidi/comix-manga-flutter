import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Berserk',
    //   description: 'A Manga',
    //   price: 29.99,
    //   imageUrl:
    //       'https://images-na.ssl-images-amazon.com/images/I/51xVYOT4mVL._SX352_BO1,204,203,200_.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'BatmanVsSuperman',
    //   description: 'A Comic',
    //   price: 59.99,
    //   imageUrl:
    //       'https://images-na.ssl-images-amazon.com/images/I/A164sMC-FaL.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Game of thrones',
    //   description: 'A Novel',
    //   price: 19.99,
    //   imageUrl:
    //       'https://images-na.ssl-images-amazon.com/images/I/51IHAPK5fsL.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Eren',
    //   description: 'A Figure',
    //   price: 49.99,
    //   imageUrl:
    //       'https://www.boxgk.com/wp-content/uploads/2022/04/Eren-Jaeger-4.jpg',
    // ),
  ];

  // var _showFavOnly = false;

  final String authToken;
  final String userId;

  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    // if (_showFavOnly) {
    //   return _items.where((prodItem) => prodItem.isFav).toList();
    // }
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFav).toList();
  }

  // void showFavOnly() {
  //   _showFavOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://comixmanga-flutter-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://comixmanga-flutter-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$authToken');
      final favResponse = await http.get(url);
      final favData = json.decode(favResponse.body);
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFav: favData == null ? false : favData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://comixmanga-flutter-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://comixmanga-flutter-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            "description": newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    final url = Uri.parse(
        'https://comixmanga-flutter-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    http.delete(url).then((_) {
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
  }
}
