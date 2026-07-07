import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/review.dart';
import 'api_service.dart';
import '../utils/constants.dart';

/// ProductProvider = otak Soal 2. Menangani:
/// - daftar produk + infinite scroll (pagination)
/// - search & filter kategori & sorting
/// - detail produk + review
class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ---- Daftar produk ----
  List<Product> products = [];
  bool isLoadingProducts = false;
  bool isLoadingMore = false;
  String? errorMessage;

  int _page = 1;
  final int _limit = 10;
  int _totalPages = 1;
  bool get hasMore => _page <= _totalPages;

  // ---- Filter & search state ----
  String searchQuery = '';
  String? selectedCategoryId; // null = semua kategori
  String sortBy = 'newest'; // price_asc | price_desc | newest

  // ---- Kategori ----
  List<Category> categories = [];

  /// Dipanggil saat pertama kali halaman dibuka, atau saat filter/search/sort berubah.
  Future<void> loadProducts({bool reset = true}) async {
    if (reset) {
      _page = 1;
      products = [];
      errorMessage = null;
    }
    isLoadingProducts = reset;
    isLoadingMore = !reset;
    notifyListeners();

    try {
      final query = {
        'page': _page.toString(),
        'limit': _limit.toString(),
        'sort': sortBy,
        if (searchQuery.isNotEmpty) 'search': searchQuery,
        if (selectedCategoryId != null) 'category_id': selectedCategoryId!,
      };
      final queryString = Uri(queryParameters: query).query;
      final result = await _api.get('${ApiConstants.products}?$queryString');

      final List<dynamic> rawList = result['data'] ?? [];
      final newProducts = rawList.map((e) => Product.fromJson(e)).toList();

      final pagination = result['pagination'];
      _totalPages =
          pagination?['totalPages'] ?? pagination?['total_pages'] ?? 1;

      if (reset) {
        products = newProducts;
      } else {
        products.addAll(newProducts);
      }
      _page++;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingProducts = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    await loadProducts(reset: false);
  }

  void setSearch(String value) {
    searchQuery = value;
    loadProducts(reset: true);
  }

  void setCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    loadProducts(reset: true);
  }

  void setSort(String value) {
    sortBy = value;
    loadProducts(reset: true);
  }

  Future<void> loadCategories() async {
    try {
      final result = await _api.get(ApiConstants.categories);
      final List<dynamic> rawList =
          result is Map ? (result['data'] ?? result) : result;
      categories = rawList.map((e) => Category.fromJson(e)).toList();
      notifyListeners();
    } on ApiException catch (_) {
      // kategori gagal dimuat -> filter chip tidak tampil, tidak fatal
    }
  }

  // ---- Detail produk ----
  Product? selectedProduct;
  bool isLoadingDetail = false;
  List<Review> reviews = [];
  bool isLoadingReviews = false;

  Future<void> loadProductDetail(String productId) async {
    isLoadingDetail = true;
    selectedProduct = null;
    notifyListeners();
    try {
      final result = await _api.get('${ApiConstants.products}/$productId');
      selectedProduct = Product.fromJson(result);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
    loadReviews(productId);
  }

  Future<void> loadReviews(String productId) async {
    isLoadingReviews = true;
    notifyListeners();
    try {
      final result =
          await _api.get('${ApiConstants.reviews}/product/$productId');
      final List<dynamic> rawList =
          result is Map ? (result['data'] ?? result) : result;
      reviews = rawList.map((e) => Review.fromJson(e)).toList();
    } on ApiException catch (_) {
      reviews = [];
    } catch (e) {
      // Tangkap error tak terduga (misal parsing gagal) supaya tidak diam-diam
      // gagal tanpa penjelasan -- tetap tampilkan sebagai list kosong, tapi
      // dicatat di console untuk debugging.
      // ignore: avoid_print
      print('⚠️ Gagal parsing reviews: $e');
      reviews = [];
    } finally {
      isLoadingReviews = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _api.post(
        '${ApiConstants.reviews}/product/$productId',
        {'rating': rating, 'comment': comment},
        withAuth: true,
      );
      await loadReviews(productId);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToCart({required String productId, int quantity = 1}) async {
    try {
      await _api.post(
        ApiConstants.cart,
        {'product_id': productId, 'quantity': quantity},
        withAuth: true,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
