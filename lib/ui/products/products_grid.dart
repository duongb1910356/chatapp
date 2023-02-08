import 'package:flutter/material.dart';
import 'product_grid_tile.dart';
import 'products_manager.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFacvorites;
  const ProductsGrid(this.showFacvorites, {super.key});

  @override
  Widget build(BuildContext context) {
    final productsManager = ProductsManager();
    final products =
        showFacvorites ? productsManager.favoriteItems : productsManager.items;
    print(products);
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductGridTile(products[i]),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
