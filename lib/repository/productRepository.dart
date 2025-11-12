import 'package:dio/dio.dart';
import '../model/productModel.dart';

class ProductRepository {
  static const String apiUrl = 'https://dummyjson.com/products';
  final Dio _dio = Dio();

  // Tüm ürünleri getir
  Future<ProductList> fetchProducts() async {
    final response = await _dio.get(apiUrl);
    return ProductList.fromJson(response.data);
  }

  // Ürün ara
  Future<ProductList> searchProducts(String query) async {
    final response = await _dio.get("$apiUrl/search?q=$query");
    return ProductList.fromJson(response.data);
  }

  // Kategoriye göre getir
  Future<ProductList> fetchByCategory(String category) async {
    final response = await _dio.get("$apiUrl/category/$category");
    return ProductList.fromJson(response.data);
  }

  // Kategorileri getir
  Future<List<String>> fetchCategories() async {
    final response = await _dio.get("$apiUrl/category-list");
    return List<String>.from(response.data);
  }
}
