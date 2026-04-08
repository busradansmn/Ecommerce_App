import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/productModel.dart';
import '../state/productProvider.dart';
import 'package:product_application/state/productNotifier.dart';

class ProductDetailsPage extends ConsumerWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  final int adet = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productNotifier = ref.read(productNotifierProvider.notifier);

    final isFavorite = ref.watch(
      productNotifierProvider.select(
        (state) => state.favoriteIds.contains(product.id),
      ),
    );

    final isShopping = ref.watch(
      productNotifierProvider.select(
        (state) => state.shoppingIds.contains(product.id),
      ),
    );

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(product.title ?? "Ürün Detayı"),
        backgroundColor: Colors.orange,
        actions: [_buildIconButtonFav(isFavorite, productNotifier)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductPicture(screenWidth, screenHeight),
              const SizedBox(height: 20),
              _buildTextTitle(),
              const SizedBox(height: 8),
              _buildRating(),
              const SizedBox(height: 16),
              _buildDiscount(),
              const SizedBox(height: 20),
              const Text(
                "Ürün Açıklaması",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.description ?? "Detay girilmemiş",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              if (product.brand != null) ...[
                _buildInfoRow("Marka", product.brand!),
                const Divider(),
              ],
              if (product.stock != null) ...[
                _buildInfoRow("Stok", "${product.stock} adet"),
                const Divider(),
              ],
              if (product.warrantyInformation != null) ...[
                _buildInfoRow("Garanti", product.warrantyInformation!),
                const Divider(),
              ],
              if (product.shippingInformation != null) ...[
                _buildInfoRow("Kargo", product.shippingInformation!),
                const Divider(),
              ],
              const SizedBox(height: 20),
              const Text(
                "Müşteri Yorumları",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (product.reviews != null && product.reviews!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: product.reviews!.length,
                  itemBuilder: (context, index) {
                    final review = product.reviews![index];
                    return _buildCardComment(review);
                  },
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Henüz yorum yok.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              _buildExpandedPrice(),
              const SizedBox(width: 12),
              _buildExpandedBasket(productNotifier, isShopping),
            ],
          ),
        ),
      ),
    );
  }


  Expanded _buildExpandedPrice() {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Toplam Fiyat",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            "\$${((product.price ?? 0) * adet).toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildExpandedBasket(
    ProductNotifier productNotifier,
    bool isShopping,
  ) {
    return Expanded(
      flex: 7,
      child: ElevatedButton.icon(
        onPressed: () {
          productNotifier.toggleShopping(product);
        },
        icon: Icon(
          isShopping ? Icons.remove_shopping_cart : Icons.shopping_cart,
          size: 24,
        ),
        label: Text(
          isShopping ? "Sepetten Çıkar" : "Sepete Ekle",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isShopping ? Colors.red : Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Card _buildCardComment(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    review.reviewerName != null &&
                            review.reviewerName!.isNotEmpty
                        ? review.reviewerName![0].toUpperCase()
                        : "?",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName ?? "Anonim",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (review.date != null)
                        Text(
                          "${review.date!.day}/${review.date!.month}/${review.date!.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (review.rating != null)
              Row(
                children: List.generate(
                  5,
                  (starIndex) => Icon(
                    starIndex < review.rating!.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            if (review.comment != null) ...[
              const SizedBox(height: 8),
              Text(review.comment!, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Row _buildDiscount() {
    return Row(
      children: [
        Text(
          "\$${product.price?.toStringAsFixed(2) ?? '0.00'}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        if (product.discountPercentage != null &&
            product.discountPercentage! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${product.discountPercentage!.toStringAsFixed(0)}% İNDİRİM",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Row _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        Text(
          " ${product.rating?.toStringAsFixed(1) ?? '0'}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Text _buildTextTitle() {
    return Text(
      product.title ?? "Ürün Başlığı",
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Center _buildProductPicture(double screenWidth, double screenHeight) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.thumbnail ?? "",
          width: screenWidth * 0.9,
          height: screenHeight * 0.4,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.4,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 100),
          ),
        ),
      ),
    );
  }

  IconButton _buildIconButtonFav(
    bool isFavorite,
    ProductNotifier productNotifier,
  ) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.white,
      ),
      onPressed: () {
        productNotifier.toggleFavorite(product);
      },
    );
  }

  // Bilgi satırı widget'ı
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
