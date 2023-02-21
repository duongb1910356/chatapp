import 'package:flutter/material.dart';
import 'package:myshop/ui/products/products_manager.dart';
import './ui/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initSate() {
    debugPrint('sdg');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
        ).copyWith(secondary: Colors.deepOrange),
      ),
      home: const ProductsOverviewScreen(),
      routes: {
        CartScreen.routeName: (ctx) => const CartScreen(),
        OrdersScreen.routeName: (ctx) => const OrdersScreen(),
        UserProductsScreen.routeName: (ctx) => const UserProductsScreen()
      },
      onGenerateRoute: (settings) {
        if (settings.name == ProductDetailScreen.routeName) {
          final productId = settings.arguments as String;
          return MaterialPageRoute(builder: (ctx) {
            return ProductDetailScreen(
              ProductsManager().findById(productId)!,
            );
          });
        }
      },
    );
  }
}
