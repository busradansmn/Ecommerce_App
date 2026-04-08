import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/productModel.dart';
import 'model/userModel.dart';
import 'screens/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Adapterleri yalnızca kayıtlı değilse ekle
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductListAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ProductAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DimensionsAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ReviewAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(MetaAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(UserModelAdapter());

  // Boxları aç
  await Hive.openBox<Product>('favorites');
  await Hive.openBox<Product>('shopping');
  await Hive.openBox<UserModel>('auth');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
