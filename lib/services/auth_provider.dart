import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// AuthProvider = "otak" modul Auth. Semua screen dengar (listen) class ini
/// lewat package `provider`, jadi status login bisa dipakai di seluruh app.
class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus status = AuthStatus.unknown;
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  /// Dipanggil sekali saat app dibuka -> cek apakah sudah pernah login (auto-login)
  Future<void> tryAutoLogin() async {
    final hasToken = await StorageService.hasToken();
    if (!hasToken) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      await fetchProfile();
      status = AuthStatus.authenticated;
    } catch (_) {
      await StorageService.clearToken();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _api.post(ApiConstants.register, {
        'full_name': fullName,
        'email': email,
        'password': password,
      });
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      // Tangkap error tak terduga (misal parsing gagal) supaya tombol
      // tidak loading selamanya dan user tetap dapat pesan error.
      errorMessage = 'Terjadi kesalahan tak terduga: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await _api.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      // NOTE: Supabase Auth biasanya membalas { user: {...}, session: { access_token: ... } }
      // Cek di Swagger lokal kamu bentuk aslinya seperti apa, sesuaikan baris di bawah.
      final token = data['session']?['access_token'] ??
          data['access_token'] ??
          data['token'];
      if (token == null) {
        throw ApiException(
            'Token tidak ditemukan pada respons API. Cek struktur response di Swagger.');
      }
      await StorageService.saveToken(token);
      await fetchProfile();

      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      // Tangkap error tak terduga (misal parsing profil gagal) supaya tombol
      // tidak loading selamanya dan user tetap dapat pesan error.
      errorMessage = 'Terjadi kesalahan tak terduga: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    final data = await _api.get(ApiConstants.profile, withAuth: true);
    currentUser = User.fromJson(data);
    notifyListeners();
  }

  Future<bool> updateProfile(
      {required String fullName, required String phoneNumber}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _api.put(
        ApiConstants.profile,
        {'full_name': fullName, 'phone_number': phoneNumber},
        withAuth: true,
      );
      await fetchProfile();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan tak terduga: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
