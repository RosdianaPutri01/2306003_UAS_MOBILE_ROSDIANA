import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_provider.dart';
import '../../services/order_provider.dart';
import '../../utils/currency_formatter.dart';
import '../home/home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    // ---- Dialog konfirmasi sebelum checkout ----
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: const Text('Pastikan alamat dan detail pesanan sudah benar. Lanjutkan membuat pesanan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Buat Pesanan')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final orderProvider = context.read<OrderProvider>();
    final order = await orderProvider.checkout(
      shippingAddress: _addressCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    if (!mounted) return;

    if (order != null) {
      // Kosongkan cart lokal & refresh badge, lalu tampilkan halaman sukses.
      await context.read<CartProvider>().loadCart();
      if (!mounted) return;
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.checkoutError ?? 'Checkout gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Pesanan Berhasil Dibuat!'),
        content: const Text('Terima kasih, pesanan kamu sedang diproses.'),
        actions: [
          FilledButton(
            onPressed: () {
              // Tutup dialog, tutup checkout, arahkan ke Home tab Pesanan
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen(initialTabIndex: 2)),
                (route) => false,
              );
            },
            child: const Text('Lihat Riwayat Pesanan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text('${item.productName} x${item.quantity}')),
                      Text(formatRupiah(item.subtotal)),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              children: [
                const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text(
                  formatRupiah(cart.grandTotal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat Pengiriman',
                hintText: 'Masukkan alamat lengkap (min. 10 karakter)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Alamat pengiriman wajib diisi';
                if (value.trim().length < 10) return 'Alamat minimal 10 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Contoh: titip di satpam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: orderProvider.isCheckingOut ? null : _handleCheckout,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: orderProvider.isCheckingOut
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Buat Pesanan'),
            ),
          ],
        ),
      ),
    );
  }
}