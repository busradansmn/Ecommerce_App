import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_application/screens/shoppingCardPage.dart';
import '../state/productProvider.dart';
import 'favoritePage.dart';
import 'homePage.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectindex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const FavoritesPage(),
    const ShoppingCardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favCount = ref.watch(
      productNotifierProvider.select((state) => state.favoriteIds.length),
    );
    final cartCount = ref.watch(
      productNotifierProvider.select((state) => state.shoppingIds.length),
    );

    return Scaffold(
      body: _screens[_selectindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[50],
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Ana Ekran',
          ),
          _buildBottomFav(favCount),
          _buildBottomBasket(cartCount),
        ],
        currentIndex: _selectindex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }

  BottomNavigationBarItem _buildBottomBasket(int cartCount) {
    return BottomNavigationBarItem(
      icon: Badge(
        isLabelVisible: cartCount > 0,
        label: Text(cartCount.toString()),
        child: const Icon(Icons.shopping_basket_rounded),
      ),
      label: 'Sepetim',
    );
  }

  BottomNavigationBarItem _buildBottomFav(int favCount) {
    return BottomNavigationBarItem(
      icon: Badge(
        isLabelVisible: favCount > 0,
        label: Text(favCount.toString()),
        child: const Icon(Icons.favorite),
      ),
      label: 'Favoriler',
    );
  }
}
