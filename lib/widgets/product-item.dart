import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../screens/product-detail-screen.dart';
import '../providers/product.dart';
import '../providers/auth.dart';

class productItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // productItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    // final productId =
    //     ModalRoute.of(context).settings.arguments as String; //the id

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              productDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.contain,
          ),
        ),
        footer: Container(
          child: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                icon: Icon(
                  product.isFav ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () {
                  product.toggleFavoriteStatus(authData.token, authData.userId);
                },
                color: Theme.of(context).accentColor,
              ),
            ),
            // leading: Consumer<Product>(
            //   builder: (context, product, child) {
            //     return IconButton(
            //       icon: Icon(Icons.abc),
            //       // product.isFav ? Icons.favorite : Icons.favorite_border ),
            //       onPressed: () {
            //         print(product.isFav);
            //       },
            //     );
            //   },
            // ),
            title: Text(
              product.title,
              style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.headline6.color,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added item to cart!',
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ),
                );
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
