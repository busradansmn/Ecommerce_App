import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_application/models/productModel.dart';
import 'package:product_application/screens/productDetailsPage.dart';
import 'package:product_application/screens/profilePage.dart';
import '../auth/authProvider.dart';
import '../state/productProvider.dart';
import 'loginPage.dart';
import 'package:product_application/state/productNotifier.dart';
import 'package:product_application/state/productState.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(productNotifierProvider.notifier).searchProducts("");
  }

  void _filterByCategory(String category) {
    ref.read(productNotifierProvider.notifier).filterByCategory(category);
  }

  void _handleLogout() {
    ref.read(authNotifierProvider.notifier).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final productNotifier = ref.read(productNotifierProvider.notifier);
    final productListAsync = productState.productList;
    final categoriesAsync = productState.categories;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBarHome(context),
      body: productListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Hata: $e")),
        data: (productList) {
          final allProducts = productList.products;
          final topDiscountedProducts = [...allProducts]
            ..sort(
              (a, b) => (b.discountPercentage ?? 0).compareTo(
                a.discountPercentage ?? 0,
              ),
            );

          final first5 = topDiscountedProducts.take(5).toList();

          double screenHeight = MediaQuery.of(context).size.height;
          double calculatedHeight = screenHeight * 0.30;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildSearch(productNotifier),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildMostSale(
                  calculatedHeight,
                  first5,
                  topDiscountedProducts,
                ),
              ),

              categoriesAsync.when(
                data: (categories) => SliverToBoxAdapter(
                  child: _builCategories(productState, categories),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, st) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                sliver: allProducts.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text("Sonuç bulunamadı"),
                          ),
                        ),
                      )
                    : _buildSliverGridProduct(allProducts, productNotifier),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverGrid _buildSliverGridProduct(
    List<Product> allProducts,
    ProductNotifier productNotifier,
  ) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        //Lazyloading Listview.builder gibi
        childCount: allProducts.length,
        (context, index) {
          final product = allProducts[index];
          final isFav = productNotifier.isFavorite(product.id);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(product: product),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ürün Resmi
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          product.thumbnail ?? "",
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Favori Butonu
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () =>
                                productNotifier.toggleFavorite(product),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                      ),
                      // İndirim Badge (varsa)
                      if ((product.discountPercentage ?? 0) > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "-${product.discountPercentage?.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Ürün Bilgileri
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${product.rating}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "\$${product.price}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Column _builCategories(ProductState productState, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            "Kategoriler",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // "Tümü" kategorisi hep sabit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  //seçim
                  label: const Text("Tümü"),
                  selected: productState.currentCategory == 'all',
                  onSelected: (_) => _filterByCategory('all'),
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.white,
                  elevation: 2,
                  labelStyle: TextStyle(
                    color: productState.currentCategory == 'all'
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Diğer kategoriler dinamik
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: productState.currentCategory == category,
                    onSelected: (_) => _filterByCategory(category),
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    labelStyle: TextStyle(
                      color: productState.currentCategory == category
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Column _buildMostSale(
    double calculatedHeight,
    List<Product> first5,
    List<Product> topDiscountedProducts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                "En Çok İndirimli Ürünler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: calculatedHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: first5.length,
            itemBuilder: (context, index) {
              final product = topDiscountedProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product),
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              product.thumbnail ?? "",
                              width: 140,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${product.discountPercentage?.toStringAsFixed(0)}% İNDİRİM",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.title ?? "",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${product.rating}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "\$${product.price}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Padding _buildSearch(ProductNotifier productNotifier) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        onChanged: (query) => productNotifier.searchProducts(query),
        decoration: InputDecoration(
          labelText: "Ürün Ara",
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
        ),
      ),
    );
  }

  AppBar _buildAppBarHome(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.orange,
      title: const Text(
        "Mağaza",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Çıkış Yap',
          onPressed: _handleLogout,
        ),
      ],
    );
  }
}
