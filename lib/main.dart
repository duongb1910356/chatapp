import 'package:flutter/material.dart';
import 'ui/products/products_manager.dart';
import 'ui/products/product_detail_screen.dart';
import './models/product.dart';

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
      home: SafeArea(
        child: ProductDetailScreen(
          Product(
            id: 'p1',
            title: 'Red Shirt',
            description: 'A red shirt - it is pretty red!',
            price: 29.99,
            imageUrl:
                'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
            isFavorite: true,
          ),
        ),
      ),
    );
  }
}
