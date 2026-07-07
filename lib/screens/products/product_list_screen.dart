import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load pertama kali. addPostFrameCallback supaya context Provider sudah siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.loadCategories();
      provider.loadProducts();
    });

    // Infinite scroll: kalau sudah dekat bawah, load halaman berikutnya.
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showSortSheet() {
    final provider = context.read<ProductProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Urutkan berdasarkan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _sortTile(ctx, provider, 'newest', 'Terbaru'),
            _sortTile(ctx, provider, 'price_asc', 'Harga Termurah'),
            _sortTile(ctx, provider, 'price_desc', 'Harga Termahal'),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(BuildContext ctx, ProductProvider provider, String value, String label) {
    return ListTile(
      title: Text(label),
      trailing: provider.sortBy == value ? const Icon(Icons.check, color: Colors.indigo) : null,
      onTap: () {
        provider.setSort(value);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortSheet),
        ],
      ),
      body: Column(
        children: [
          // ---- Search bar ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.setSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onSubmitted: (value) => provider.setSearch(value.trim()),
            ),
          ),

          // ---- Filter kategori (Chip) ----
          if (provider.categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Semua'),
                      selected: provider.selectedCategoryId == null,
                      onSelected: (_) => provider.setCategory(null),
                    ),
                  ),
                  ...provider.categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.name),
                          selected: provider.selectedCategoryId == cat.id,
                          onSelected: (_) => provider.setCategory(cat.id),
                        ),
                      )),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // ---- Grid produk ----
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(provider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => provider.loadProducts(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('Produk tidak ditemukan'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadProducts(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsif: HP sempit tetap 2 kolom, layar lebar (tablet/web) otomatis nambah kolom
          // biar card gak jadi kelebaran/kegedean.
          final crossAxisCount = (constraints.maxWidth / 220).floor().clamp(2, 6);

          return GridView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: provider.products.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.products.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final product = provider.products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}