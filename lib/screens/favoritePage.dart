import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/productProvider.dart';
import 'package:product_application/models/productModel.dart';
import 'package:product_application/state/productNotifier.dart';
import 'productdetailsPage.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(
      productNotifierProvider.select((state) => state.favoriteIds),
    );
    final localRepo = ref.read(localDataRepositoryProvider);

    final favorites = localRepo
        .getAllFavorites()
        .where((p) => favorite.contains(p.id))
        .toList();

    final productNotifier = ref.read(productNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Favorilerim",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Henüz favori ürün yok",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return _buildCardFav(context, product, productNotifier);
              },
            ),
    );
  }

  Card _buildCardFav(
    BuildContext context,
    Product product,
    ProductNotifier productNotifier,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      elevation: 1,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.thumbnail ?? "",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "\$${product.price}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  productNotifier.toggleFavorite(product);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
