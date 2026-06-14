import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import 'wuthering_login_page.dart';
import 'wuthering_katalog_page.dart';
import 'wuthering_favorites_page.dart';
import 'wuthering_terminal_page.dart';
import 'cart_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  // Page titles per tab
  static const _titles = ['ECHOES', 'FAVORITES', 'TERMINAL'];

  // Page icons per tab (unselected / selected)
  static const _icons = [
    [Icons.explore_outlined, Icons.explore],
    [Icons.favorite_outline, Icons.favorite],
    [Icons.receipt_long_outlined, Icons.receipt_long],
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = Provider.of<CartProvider>(context).itemCount;
    final favCount = Provider.of<FavoritesProvider>(context).favorites.length;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          // Cart icon (only shown on Echoes tab)
          if (_currentIndex == 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: AppTheme.primaryColor),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: AppTheme.darkBg,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WutheringLoginPage()),
              );
            },
          ),
        ],
      ),
      // IndexedStack preserves state on all three pages
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          WutheringKatalogPage(),
          WutheringFavoritesPage(),
          WutheringTerminalPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.6),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: AppTheme.cardColor,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(_icons[0][0] as IconData),
              activeIcon: Icon(_icons[0][1] as IconData),
              label: 'Echoes',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(_icons[1][0] as IconData),
                  if (favCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$favCount',
                          style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Icon(_icons[1][1] as IconData),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(_icons[2][0] as IconData),
              activeIcon: Icon(_icons[2][1] as IconData),
              label: 'Terminal',
            ),
          ],
        ),
      ),
    );
  }
}
