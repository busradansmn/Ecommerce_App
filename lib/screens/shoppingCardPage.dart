import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/productModel.dart';
import '../state/productProvider.dart';
import 'orderSuccessPage.dart';
import 'package:product_application/state/productNotifier.dart';
import 'productdetailsPage.dart';

class ShoppingCardPage extends ConsumerWidget {
  const ShoppingCardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingIds = ref.watch(
      productNotifierProvider.select((state) => state.shoppingIds),
    );
    final localRepo = ref.read(localDataRepositoryProvider);

    final shoppingList = localRepo
        .getAllShopping()
        .where((p) => shoppingIds.contains(p.id))
        .toList();

    final productNotifier = ref.read(productNotifierProvider.notifier);
    double subtotal = 0.0;
    double totalDiscount = 0.0;

    void calculateTotalsForItem(Product item) {
      final price = item.price ?? 0.0;
      final discountPercent = item.discountPercentage ?? 0.0;
      final discountAmount = price * (discountPercent / 100);

      subtotal += price;
      totalDiscount += discountAmount;
    }

    for (var item in shoppingList) {
      calculateTotalsForItem(item);
    }

    final totalPrice = subtotal - totalDiscount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: const Text(
          "Sepetim",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (shoppingList.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${shoppingList.length} Ürün",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: shoppingList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              "Sepetiniz Boş",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Alışverişe başlamak için ürün ekleyin",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: shoppingList.length,
        itemBuilder: (context, index) {
          final shopping = shoppingList[index];
          final price = shopping.price ?? 0.0;
          final discountPercent = shopping.discountPercentage ?? 0.0;
          final discountedPrice =
              price - (price * (discountPercent / 100));

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(product: shopping),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildClipRRect(shopping),
                    const SizedBox(width: 12),
                    _buildExpanded(
                      shopping,
                      discountPercent,
                      price,
                      discountedPrice,
                    ),
                    _buildIconButton(productNotifier, shopping, context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: shoppingList.isEmpty
          ? null
          : _buildNotEmptyList(
        subtotal,
        totalDiscount,
        totalPrice,
        shoppingList,
        context,
      ),
    );
  }

  Container _buildNotEmptyList(
      double subtotal,
      double totalDiscount,
      double totalPrice,
      List<Product> shoppingList,
      BuildContext context,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ara Toplam:",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Text(
                  "\$${subtotal.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "İndirim:",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
                Text(
                  "-\$${totalDiscount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Toplam:",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSuccessPage(
                        shoppingList: shoppingList,
                        subtotal: subtotal,
                        totalDiscount: totalDiscount,
                        totalPrice: totalPrice,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Siparişi Tamamla",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconButton _buildIconButton(
      ProductNotifier productNotifier,
      Product shopping,
      BuildContext context,
      ) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: () {
        productNotifier.toggleShopping(shopping);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Ürün sepetten çıkarıldı"),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Expanded _buildExpanded(
      Product shopping,
      double discountPercent,
      double price,
      double discountedPrice,
      ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shopping.title ?? "",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (discountPercent > 0) ...[
            Row(
              children: [
                Text(
                  "\$${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "-${discountPercent.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            "\$${discountedPrice.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  ClipRRect _buildClipRRect(Product shopping) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        shopping.thumbnail ?? "",
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }
}