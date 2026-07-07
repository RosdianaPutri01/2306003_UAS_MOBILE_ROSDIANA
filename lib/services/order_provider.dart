import 'package:flutter/material.dart';
import '../models/order.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ---- Checkout ----
  bool isCheckingOut = false;
  String? checkoutError;

  Future<Order?> checkout({required String shippingAddress, String? notes}) async {
    isCheckingOut = true;
    checkoutError = null;
    notifyListeners();
    try {
      final result = await _api.post(
        ApiConstants.orders,
        {
          'shipping_address': shippingAddress,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        withAuth: true,
      );
      isCheckingOut = false;
      notifyListeners();
      return Order.fromJson(result);
    } on ApiException catch (e) {
      checkoutError = e.message;
      isCheckingOut = false;
      notifyListeners();
      return null;
    }
  }

  // ---- Riwayat pesanan (pagination) ----
  List<Order> orders = [];
  bool isLoadingOrders = false;
  bool isLoadingMore = false;
  String? errorMessage;
  int _page = 1;
  final int _limit = 10;
  int _totalPages = 1;
  bool get hasMore => _page <= _totalPages;

  Future<void> loadOrders({bool reset = true}) async {
    if (reset) {
      _page = 1;
      orders = [];
      errorMessage = null;
    }
    isLoadingOrders = reset;
    isLoadingMore = !reset;
    notifyListeners();
    try {
      final result = await _api.get(
        '${ApiConstants.orders}?page=$_page&limit=$_limit',
        withAuth: true,
      );
      final List<dynamic> rawList = result['data'] ?? [];
      final newOrders = rawList.map((e) => Order.fromJson(e)).toList();

      final pagination = result['pagination'];
      _totalPages = pagination?['totalPages'] ?? pagination?['total_pages'] ?? 1;

      if (reset) {
        orders = newOrders;
      } else {
        orders.addAll(newOrders);
      }
      _page++;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingOrders = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    await loadOrders(reset: false);
  }

  // ---- Detail pesanan ----
  Order? selectedOrder;
  bool isLoadingDetail = false;

  Future<void> loadOrderDetail(String orderId) async {
    isLoadingDetail = true;
    selectedOrder = null;
    notifyListeners();
    try {
      final result = await _api.get('${ApiConstants.orders}/$orderId', withAuth: true);
      selectedOrder = Order.fromJson(result);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }
}