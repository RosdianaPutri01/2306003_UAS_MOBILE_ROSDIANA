import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'api_service.dart';
import '../utils/constants.dart';

/// CartProvider = otak Soal 3. Semua screen yang butuh info keranjang
/// (badge counter di nav bar, halaman cart, dst) dengar class ini.
class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CartItem> items = [];
  bool isLoading = false;
  String? errorMessage;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  num get grandTotal => items.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> loadCart() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.get(ApiConstants.cart, withAuth: true);
      final List<dynamic> rawList = result is Map ? (result['data'] ?? result['items'] ?? []) : result;
      items = rawList.map((e) => CartItem.fromJson(e)).toList();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return false;
    try {
      await _api.put(
        '${ApiConstants.cart}/$cartItemId',
        {'quantity': newQuantity},
        withAuth: true,
      );
      await loadCart();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    try {
      await _api.delete('${ApiConstants.cart}/$cartItemId', withAuth: true);
      items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      await _api.delete(ApiConstants.cart, withAuth: true);
      items = [];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}