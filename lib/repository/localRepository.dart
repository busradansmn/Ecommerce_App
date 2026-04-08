import 'package:hive/hive.dart';
import '../models/productModel.dart';

class LocalDataRepository {

  static const String _favoriteBoxName = "favorites";
  static const String _shoppingBoxName = "shopping";

  Box<Product> get _favoriteBox => Hive.box<Product>(_favoriteBoxName);
  Box<Product> get _shoppingBox => Hive.box<Product>(_shoppingBoxName);

  // --- Favori İşlemleri ---

  Future<void> addFavorite(Product product) async {
    await _favoriteBox.put(product.id.toString(), product);
  }

  Future<void> removeFavorite(int id) async {
    await _favoriteBox.delete(id.toString());
  }

  List<Product> getAllFavorites() {
    return _favoriteBox.values.toList();
  }

  bool isFavorite(int? id) {
    if (id == null) return false;
    return _favoriteBox.containsKey(id.toString());
  }

  int getFavoriteCount() => _favoriteBox.length;


  // --- Sepet İşlemleri ---

  Future<void> addShopping(Product product) async {
    await _shoppingBox.put(product.id.toString(), product);
  }

  Future<void> removeShopping(int id) async {
    await _shoppingBox.delete(id.toString());
  }

  List<Product> getAllShopping() {
    return _shoppingBox.values.toList();
  }

  bool isShopping(int? id) {
    if (id == null) return false;
    return _shoppingBox.containsKey(id.toString());
  }

  int getShoppingCount() => _shoppingBox.length;
}
