import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/profile_screen.dart';
import '../products/product_list_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../../services/cart_provider.dart';
import '../../services/auth_provider.dart';
import '../../widgets/require_login.dart';

/// HomeScreen adalah SHELL dengan bottom navigation.
/// Mode Guest (kayak Shopee): tab "Produk" selalu bisa diakses tanpa login.
/// Tab "Keranjang", "Pesanan", "Profil" butuh login -> kalau guest,
/// ditampilkan RequireLoginPlaceholder alih-alih konten aslinya.
class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cart cuma dimuat kalau sudah login (endpoint /cart butuh token)
      final auth = context.read<AuthProvider>();
      if (auth.status == AuthStatus.authenticated) {
        context.read<CartProvider>().loadCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().status == AuthStatus.authenticated;
    final cartCount = isLoggedIn ? context.watch<CartProvider>().totalItemCount : 0;

    final pages = [
      const ProductListScreen(), // selalu bisa diakses, walau guest
      isLoggedIn
          ? const CartScreen()
          : const RequireLoginPlaceholder(message: 'Login dulu untuk melihat keranjang belanja kamu'),
      isLoggedIn
          ? const OrderHistoryScreen()
          : const RequireLoginPlaceholder(message: 'Login dulu untuk melihat riwayat pesanan kamu'),
      isLoggedIn
          ? const ProfileScreen()
          : const RequireLoginPlaceholder(message: 'Login dulu untuk melihat profil kamu'),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          // Begitu pindah ke tab Keranjang dan sudah login, refresh datanya
          if (i == 1 && isLoggedIn) {
            context.read<CartProvider>().loadCart();
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}