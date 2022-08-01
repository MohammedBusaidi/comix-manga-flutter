import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/products-overview-screen.dart';

import 'package:provider/provider.dart';

import './screens/product-detail-screen.dart';
import './providers/products-provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

import './screens/cart-screen.dart';
import './screens/orders-screen.dart';
import './screens/user-products-screen.dart';
import './screens/edit-product-screen.dart';
import './screens/auth-screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      // you can use the .value on single list or grid items, or the create: (ctx) => The Class, when use intitate a new calss
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ComixManga',
          theme: ThemeData(
            primarySwatch: Colors.red,
            accentColor: Colors.amber,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth ? productsOverviewScreen() : authScreen(),
          routes: {
            productDetailScreen.routeName: (ctx) => productDetailScreen(),
            cartScreen.routeName: (ctx) => cartScreen(),
            ordersScreen.routeName: (ctx) => ordersScreen(),
            userProductsScreen.routeName: (ctx) => userProductsScreen(),
            editProductScreen.routeName: (ctx) => editProductScreen(),
          },
        ),
      ),
    );
  }
}
