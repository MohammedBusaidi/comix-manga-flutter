import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products-provider.dart';
import '../widgets/user-product-item.dart';
import '../widgets/drawer.dart';
import './edit-product-screen.dart';

class userProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<Void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    print('rebuilding...');
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(editProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: appDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            userProductItem(
                              productsData.items[i].id,
                              productsData.items[i].title,
                              productsData.items[i].imageUrl,
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
