import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'services/product_provider.dart';
import 'services/cart_provider.dart';
import 'services/order_provider.dart';
import 'services/admin_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'UAS Mobile - E-Commerce',
        debugShowCheckedModeBanner: false,
        theme: _buildPinkTheme(),
        home: const AuthGate(),
      ),
    );
  }

  ThemeData _buildPinkTheme() {
    const pinkPrimary = Color(0xFFE91E63); // pink utama
    const pinkDark = Color(0xFFAD1457);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: pinkPrimary,
      primary: pinkPrimary,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor:
          const Color(0xFFFFF5F8), 
      appBarTheme: AppBarTheme(
        backgroundColor: pinkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.pink.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.pink.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: pinkPrimary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pinkPrimary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pinkDark,
          side: BorderSide(color: pinkPrimary.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: pinkPrimary,
        backgroundColor: Colors.pink.shade50,
        labelStyle: const TextStyle(fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: StadiumBorder(side: BorderSide(color: Colors.pink.shade100)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: pinkPrimary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? pinkDark : Colors.grey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? pinkDark : Colors.grey);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: Color(0xFFE91E63),
        textColor: Colors.white,
      ),
    );
  }
}

/// AuthGate menentukan halaman pertama yang tampil:
/// - Sedang mengecek token -> loading
/// - Ada token valid -> HomeScreen (auto-login, Soal 1B)
/// - Tidak ada token -> LoginScreen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Jalankan setelah frame pertama supaya context provider sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        // Halaman admin TERPISAH dari halaman user biasa (syarat Soal 5 Opsi A)
        final role = auth.currentUser?.role?.toLowerCase();
        if (role == 'admin') {
          return const AdminHomeScreen();
        }
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        // Mode Guest (kayak Shopee): boleh lihat-lihat produk tanpa login.
        // Login baru diwajibkan saat mau tambah ke keranjang / checkout / lihat profil.
        return const HomeScreen();
    }
  }
}
