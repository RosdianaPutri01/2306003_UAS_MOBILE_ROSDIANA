import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/product_provider.dart';
import '../../services/auth_provider.dart';
import '../../services/cart_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/require_login.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _reviewRating = 5;
  final _commentCtrl = TextEditingController();
  bool _submittingReview = false;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductDetail(widget.productId);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final isLoggedIn =
        context.read<AuthProvider>().status == AuthStatus.authenticated;
    final canProceed = await requireLogin(context, isLoggedIn);
    if (!canProceed || !mounted) return;

    setState(() => _addingToCart = true);
    final success = await context
        .read<ProductProvider>()
        .addToCart(productId: widget.productId);
    if (!mounted) return;
    setState(() => _addingToCart = false);
    if (success) {
      // Refresh badge counter di nav bar
      context.read<CartProvider>().loadCart();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Berhasil ditambahkan ke keranjang'
            : 'Gagal menambahkan ke keranjang'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Komentar tidak boleh kosong'),
            backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submittingReview = true);
    final success = await context.read<ProductProvider>().submitReview(
          productId: widget.productId,
          rating: _reviewRating,
          comment: _commentCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submittingReview = false);
    if (success) _commentCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success ? 'Ulasan berhasil dikirim' : 'Gagal mengirim ulasan'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final isLoggedIn =
        context.watch<AuthProvider>().status == AuthStatus.authenticated;
    final product = provider.selectedProduct;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: provider.isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Produk tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child:
                          product.imageUrl == null || product.imageUrl!.isEmpty
                              ? Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 64,
                                      color: Colors.grey),
                                )
                              : CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            formatRupiah(product.price),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (product.category != null)
                                Chip(label: Text(product.category!.name)),
                              Chip(
                                label: Text('Stok: ${product.stock}'),
                                backgroundColor: product.stock > 0
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                              ),
                              if (provider.reviews.isNotEmpty)
                                Chip(
                                  avatar: const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  label: Text(
                                      '${_averageRating(provider.reviews).toStringAsFixed(1)} (${provider.reviews.length})'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Deskripsi',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(product.description.isEmpty
                              ? '-'
                              : product.description),
                          const SizedBox(height: 24),

                          FilledButton.icon(
                            onPressed: (product.stock <= 0 || _addingToCart)
                                ? null
                                : _addToCart,
                            icon: _addingToCart
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.add_shopping_cart),
                            label: Text(product.stock <= 0
                                ? 'Stok Habis'
                                : 'Tambah ke Keranjang'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),

                          const Divider(height: 40),

                          // ---- Daftar ulasan ----
                          Text('Ulasan (${provider.reviews.length})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (provider.isLoadingReviews)
                            const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator()))
                          else if (provider.reviews.isEmpty)
                            const Text('Belum ada ulasan untuk produk ini.',
                                style: TextStyle(color: Colors.grey))
                          else
                            ...provider.reviews.map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(r.userName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 8),
                                          RatingBarIndicator(
                                            rating: r.rating.toDouble(),
                                            itemCount: 5,
                                            itemSize: 14,
                                            itemBuilder: (_, __) => const Icon(
                                                Icons.star,
                                                color: Colors.amber),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(r.comment),
                                    ],
                                  ),
                                )),

                          const Divider(height: 40),

                          // ---- Form ulasan baru (hanya jika login) ----
                          if (isLoggedIn) ...[
                            const Text('Tulis Ulasan',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            RatingBar.builder(
                              initialRating: _reviewRating.toDouble(),
                              minRating: 1,
                              itemCount: 5,
                              itemSize: 32,
                              itemBuilder: (_, __) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (value) =>
                                  setState(() => _reviewRating = value.toInt()),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _commentCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Tulis komentar kamu...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed:
                                  _submittingReview ? null : _submitReview,
                              child: _submittingReview
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Text('Kirim Ulasan'),
                            ),
                          ] else
                            const Text('Login untuk menulis ulasan.',
                                style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  double _averageRating(List reviews) {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (sum, r) => sum + (r.rating as int));
    return total / reviews.length;
  }
}
