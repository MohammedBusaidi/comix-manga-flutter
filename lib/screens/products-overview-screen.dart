import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products-grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../screens/cart-screen.dart';
import '../widgets/drawer.dart';
import '../providers/products-provider.dart';

enum filterOptions {
  Favorites,
  All,
}

class productsOverviewScreen extends StatefulWidget {
  @override
  _productsOverviewScreenState createState() => _productsOverviewScreenState();
}

class _productsOverviewScreenState extends State<productsOverviewScreen> {
  var _showOnlyFav = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ComixManga'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (filterOptions selectedValue) {
              setState(() {
                if (selectedValue == filterOptions.Favorites) {
                  _showOnlyFav = true;
                } else {
                  _showOnlyFav = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Favorites'),
                value: filterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('All Items'),
                value: filterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(cartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: appDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : productsGrid(_showOnlyFav),
    );
  }
}
