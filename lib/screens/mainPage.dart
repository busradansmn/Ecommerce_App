import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/productProvider.dart';
import 'favoritePage.dart';
import 'homePage.dart';
import 'shoppingcardPage.dart';

//yönlendirmeleri yönetmek ve durum bilgisini bir noktada görüntülemek
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
    const ShoppingcardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Favori ve Sepet ID'lerini izle
    final favCount = ref.watch(productNotifierProvider.select((state) => state.favoriteIds.length));
    final cartCount = ref.watch(productNotifierProvider.select((state) => state.shoppingIds.length));

    return Scaffold(
      body: _screens[_selectindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[50],
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Ana Ekran',
          ),
          BottomNavigationBarItem(
            icon: Badge( // Favori sayısını göstermek için Badge
              isLabelVisible: favCount > 0,
              label: Text(favCount.toString()),
              child: const Icon(Icons.favorite),
            ),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Badge( // Sepet sayısını göstermek için Badge
              isLabelVisible: cartCount > 0,
              label: Text(cartCount.toString()),
              child: const Icon(Icons.shopping_basket_rounded),
            ),
            label: 'Sepetim',
          ),
        ],
        currentIndex: _selectindex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}