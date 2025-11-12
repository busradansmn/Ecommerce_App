import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/productModel.dart';

//tüm veriyi tek bir kutuya (nesneye) koymak
class ProductState {
  final AsyncValue<ProductList> productList;
  final AsyncValue<List<String>> categories;
  final Set<int> favoriteIds;
  final Set<int> shoppingIds;
  final String searchQuery;
  final String currentCategory;
  final List<Product> allProducts;

  ProductState({
    required this.productList,
    required this.categories,
    required this.favoriteIds,
    required this.shoppingIds,
    required this.searchQuery,
    required this.currentCategory,
    required this.allProducts,
  });

  factory ProductState.initial() => ProductState(
    productList: const AsyncValue.loading(),
    categories: const AsyncValue.loading(),
    favoriteIds: {},
    shoppingIds: {},
    searchQuery: '',
    currentCategory: 'all',
    allProducts: [],
  );

  ProductState copyWith({
    AsyncValue<ProductList>? productList,
    AsyncValue<List<String>>? categories,
    Set<int>? favoriteIds,
    Set<int>? shoppingIds,
    String? searchQuery,
    String? currentCategory,
    List<Product>? allProducts,
  }) {
    return ProductState(
      productList: productList ?? this.productList,
      categories: categories ?? this.categories,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      shoppingIds: shoppingIds ?? this.shoppingIds,
      searchQuery: searchQuery ?? this.searchQuery,
      currentCategory: currentCategory ?? this.currentCategory,
      allProducts: allProducts ?? this.allProducts,
    );
  }
}
