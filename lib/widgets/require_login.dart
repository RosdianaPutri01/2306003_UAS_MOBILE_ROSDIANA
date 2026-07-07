import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';

/// Ditampilkan menggantikan konten tab (Keranjang/Pesanan/Profil) kalau
/// user masih guest (belum login). Mirip pola Shopee: boleh lihat produk,
/// tapi begitu masuk area yang butuh akun, diarahkan login dulu.
class RequireLoginPlaceholder extends StatelessWidget {
  final String message;
  const RequireLoginPlaceholder(
      {super.key,
      this.message = 'Login diperlukan untuk mengakses halaman ini'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Login Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper: cek status login, kalau belum login munculkan dialog
/// yang mengarahkan ke LoginScreen. Return true kalau SUDAH login
/// (jadi aksi asli boleh dilanjutkan), false kalau belum.
Future<bool> requireLogin(BuildContext context, bool isLoggedIn) async {
  if (isLoggedIn) return true;

  final shouldLogin = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Login Diperlukan'),
      content: const Text('Login Untuk Melanjutkan.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Login')),
      ],
    ),
  );

  if (shouldLogin == true && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
  return false; // aksi asli tetap dibatalkan kali ini, user harus tap tombolnya lagi setelah login
}
