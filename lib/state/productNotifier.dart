import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:product_application/state/productState.dart';
import '../model/productModel.dart';
import '../repository/localRepository.dart';
import '../repository/productRepository.dart';

class ProductNotifier extends StateNotifier<ProductState> {

  final ProductRepository _productRepo;
  final LocalDataRepository _localDataRepo;

  ProductNotifier(this._productRepo, this._localDataRepo)
    : super(ProductState.initial()) {
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
      _loadFavoriteIds(),
      _loadShoppingIds(),
    ]);
  }

  Future<void> _loadShoppingIds() async {
    final shoppingItems = _localDataRepo.getAllShopping();
    final Set<int> ids = shoppingItems
        .where((p) => p.id != null)
        .map((p) => p.id!)
        .toSet();
    state = state.copyWith(shoppingIds: ids);
  }

  // --- ÜRÜNLERİ YÜKLEME ---
  Future<void> _loadProducts() async {
    state = state.copyWith(productList: const AsyncValue.loading());
    try {
      ProductList result;
      if (state.currentCategory != 'all') {
        result = await _productRepo.fetchByCategory(state.currentCategory);
      } else {
        result = await _productRepo.fetchProducts();
      }

      // Tüm ürünleri allProducts'a kaydet
      state = state.copyWith(
        productList: AsyncValue.data(result),
        allProducts: result.products,
      );

      // Eğer arama varsa, lokal filtreleme yap
      if (state.searchQuery.isNotEmpty) {
        _filterLocalProducts();
      }
    } catch (e, st) {
      state = state.copyWith(
        productList: AsyncValue.error('Ürünler yüklenemedi: $e', st),
      );
    }
  }

  // --- KATEGORİLERİ YÜKLEME ---
  Future<void> _loadCategories() async {
    try {
      final categories = await _productRepo.fetchCategories();
      state = state.copyWith(categories: AsyncValue.data(categories));
    } catch (e, st) {
      state = state.copyWith(
        categories: AsyncValue.error('Kategoriler yüklenemedi: $e', st),
      );
    }
  }

  // --- FAVORİ ID'LERİ YÜKLEME ---
  Future<void> _loadFavoriteIds() async {
    final favorites = _localDataRepo.getAllFavorites();
    final Set<int> ids = favorites
        .where((p) => p.id != null)
        .map((p) => p.id!)
        .toSet();
    state = state.copyWith(favoriteIds: ids);
  }

  // LOKAL FİLTRELEME - API çağırmadan
  void _filterLocalProducts() {
    final query = state.searchQuery.toLowerCase();
    final allProds = state.allProducts;

    if (query.isEmpty) {
      // Arama yoksa tüm ürünleri göster
      state = state.copyWith(
        productList: AsyncValue.data(
          ProductList(
            products: allProds,
            total: allProds.length,
            skip: 0,
            limit: allProds.length,
          ),
        ),
      );
    } else {
      // Arama varsa filtrele
      final filtered = allProds.where((product) {
        final title = (product.title ?? '').toLowerCase();
        final description = (product.description ?? '').toLowerCase();
        final category = (product.category ?? '').toLowerCase();

        return title.contains(query) ||
            description.contains(query) ||
            category.contains(query);
      }).toList();

      state = state.copyWith(
        productList: AsyncValue.data(
          ProductList(
            products: filtered,
            total: filtered.length,
            skip: 0,
            limit: filtered.length,
          ),
        ),
      );
    }
  }

  // Arama yap - LOKAL, API çağırmadan
  void searchProducts(String query) {
    final trimmedQuery = query.trim();
    if (state.searchQuery == trimmedQuery) return;

    state = state.copyWith(searchQuery: trimmedQuery, currentCategory: 'all');

    // Sadece lokal filtreleme yap
    _filterLocalProducts();
  }

  // Kategoriye göre filtrele
  void filterByCategory(String category) {
    if (state.currentCategory == category) return;

    state = state.copyWith(currentCategory: category, searchQuery: '');
    _loadProducts();
  }

  // Favori durumunu değiştir
  Future<void> toggleFavorite(Product product) async {
    if (product.id == null) return;

    final id = product.id!;
    final newFavorites = Set<int>.from(state.favoriteIds);

    if (newFavorites.contains(id)) {
      await _localDataRepo.removeFavorite(id);
      newFavorites.remove(id);
    } else {
      await _localDataRepo.addFavorite(product);
      newFavorites.add(id);
    }
    state = state.copyWith(favoriteIds: newFavorites);
  }

  // --- SEPET İŞLEMLERİ ---
  Future<void> toggleShopping(Product product) async {
    if (product.id == null) return;

    final id = product.id!;
    final newShoppingIds = Set<int>.from(state.shoppingIds);

    if (newShoppingIds.contains(id)) {
      await _localDataRepo.removeShopping(id);
      newShoppingIds.remove(id);
    } else {
      await _localDataRepo.addShopping(product);
      newShoppingIds.add(id);
    }
    state = state.copyWith(shoppingIds: newShoppingIds);
  }

  // Sepet kontrolü
  bool isShopping(int? id) {
    if (id == null) return false;
    return state.shoppingIds.contains(id);
  }

  // Ürünün favori olup olmadığını kontrol et
  bool isFavorite(int? id) {
    if (id == null) return false;
    return state.favoriteIds.contains(id);
  }
}
