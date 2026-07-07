import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../models/order.dart';
import 'api_service.dart';
import '../utils/constants.dart';

/// Urutan status yang valid -- dipakai untuk validasi transisi status.
/// Aturan sederhana: status hanya boleh maju, tidak boleh mundur,
/// dan 'delivered' / 'cancelled' adalah status akhir (tidak bisa diubah lagi).
const List<String> kOrderStatusFlow = [
  'pending',
  'processing',
  'shipped',
  'delivered'
];

bool isValidStatusTransition(String current, String next) {
  if (current == next) return false;
  if (current == 'delivered' || current == 'cancelled') {
    return false; // status akhir, tidak bisa diubah
  }
  // Sesuai alur resmi backend: cancel HANYA bisa dari pending atau processing, bukan dari shipped.
  if (next == 'cancelled') {
    return current == 'pending' || current == 'processing';
  }
  final currentIndex = kOrderStatusFlow.indexOf(current);
  final nextIndex = kOrderStatusFlow.indexOf(next);
  if (currentIndex == -1 || nextIndex == -1) return false;
  return nextIndex > currentIndex; // hanya boleh maju, tidak boleh mundur
}

class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ---- Statistik ----
  DashboardStats? stats;
  bool isLoadingStats = false;
  String? statsError;

  Future<void> loadStats() async {
    isLoadingStats = true;
    statsError = null;
    notifyListeners();
    try {
      final result =
          await _api.get('${ApiConstants.dashboard}/stats', withAuth: true);
      stats = DashboardStats.fromJson(result);
    } on ApiException catch (e) {
      statsError = e.message;
    } finally {
      isLoadingStats = false;
      notifyListeners();
    }
  }

  // ---- Produk terlaris ----
  List<TopProduct> topProducts = [];
  bool isLoadingTopProducts = false;

  Future<void> loadTopProducts() async {
    isLoadingTopProducts = true;
    notifyListeners();
    try {
      final result = await _api.get('${ApiConstants.dashboard}/top-products',
          withAuth: true);
      // Dikonfirmasi dari dashboard.controller.js: response-nya { total, products: [...] },
      // jadi list-nya ada di dalam key "products", bukan langsung array.
      final List<dynamic> rawList =
          result is Map ? (result['products'] ?? []) : result;
      topProducts = rawList.map((e) => TopProduct.fromJson(e)).toList();
    } on ApiException catch (_) {
      topProducts = [];
    } finally {
      isLoadingTopProducts = false;
      notifyListeners();
    }
  }

  // ---- Manajemen pesanan ----
  List<Order> adminOrders = [];
  bool isLoadingOrders = false;
  String? ordersError;
  String? statusFilter; // null = semua status

  Future<void> loadAdminOrders() async {
    isLoadingOrders = true;
    ordersError = null;
    notifyListeners();
    try {
      final query = statusFilter != null ? '?status=$statusFilter' : '';
      final result = await _api.get('${ApiConstants.orders}/admin/all$query',
          withAuth: true);
      final List<dynamic> rawList =
          result is Map ? (result['data'] ?? result) : result;
      adminOrders = rawList.map((e) => Order.fromJson(e)).toList();
    } on ApiException catch (e) {
      ordersError = e.message;
    } finally {
      isLoadingOrders = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    statusFilter = status;
    loadAdminOrders();
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _api.put(
          '${ApiConstants.orders}/$orderId/status', {'status': newStatus},
          withAuth: true);
      await loadAdminOrders();
      return true;
    } on ApiException catch (e) {
      ordersError = e.message;
      notifyListeners();
      return false;
    }
  }
}
