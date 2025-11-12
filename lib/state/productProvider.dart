import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:product_application/state/productNotifier.dart';
import 'package:product_application/state/productState.dart';
import '../repository/localRepository.dart';
import '../repository/productRepository.dart';

//Servis Sağlayıcıları
final productRepositoryProvider = Provider((ref) => ProductRepository());
final localDataRepositoryProvider = Provider((ref) => LocalDataRepository());

//ProductNotifier sınıfının örneğini oluşturur.
final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
      final productRepo = ref.watch(productRepositoryProvider);
      final localRepo = ref.watch(localDataRepositoryProvider);
      return ProductNotifier(productRepo, localRepo);
    });
