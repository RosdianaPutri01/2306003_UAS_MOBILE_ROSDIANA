import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'storage_service.dart';

/// Exception kustom supaya pesan error dari API gampang ditangkap & ditampilkan di UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Semua modul (auth, products, cart, orders, dst) HARUS lewat class ini
/// untuk bicara ke API. Screens TIDAK BOLEH import package:http langsung.
///
/// Backend ini selalu membalas dengan format:
/// Sukses  : { "success": true,  "message": "...", "data": {...} }
/// Error   : { "success": false, "message": "...", "errors": [...] }
/// Jadi class ini otomatis membuka (unwrap) key "data" dan melempar
/// ApiException kalau "success" bernilai false.
class ApiService {
  Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await StorageService.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final Map<String, dynamic> body =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};

    final bool success = body['success'] == true;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      // Kembalikan isi "data" saja. Kalau backend juga kirim "pagination",
      // kita gabungkan supaya screen bisa akses keduanya.
      final data = body['data'];
      if (body.containsKey('pagination')) {
        return {'data': data, 'pagination': body['pagination']};
      }
      return data;
    }

    // Ambil pesan error yang paling informatif
    String message = body['message']?.toString() ?? 'Terjadi kesalahan (${response.statusCode})';
    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final firstError = (body['errors'] as List).first;
      if (firstError is Map && firstError['msg'] != null) {
        message = firstError['msg'].toString();
      }
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> get(String endpoint, {bool withAuth = false}) async {
    try {
      // Tambahkan parameter unik (timestamp) supaya URL request selalu beda
      // dan browser gak punya alasan buat pakai cache lama -- terutama
      // penting untuk GET /auth/profile yang sering dipanggil ulang
      // setelah login/register dengan akun berbeda.
      final separator = endpoint.contains('?') ? '&' : '?';
      final cacheBustedEndpoint = '$endpoint${separator}_t=${DateTime.now().millisecondsSinceEpoch}';

      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}$cacheBustedEndpoint'),
              headers: await _headers(withAuth: withAuth))
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal terhubung ke server. Periksa koneksi/URL server kamu.');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool withAuth = false}) async {
    try {
      final response = await http
          .post(Uri.parse('${ApiConstants.baseUrl}$endpoint'),
              headers: await _headers(withAuth: withAuth), body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal terhubung ke server. Periksa koneksi/URL server kamu.');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool withAuth = false}) async {
    try {
      final response = await http
          .put(Uri.parse('${ApiConstants.baseUrl}$endpoint'),
              headers: await _headers(withAuth: withAuth), body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal terhubung ke server. Periksa koneksi/URL server kamu.');
    }
  }

  Future<dynamic> delete(String endpoint, {bool withAuth = false}) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConstants.baseUrl}$endpoint'),
              headers: await _headers(withAuth: withAuth))
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal terhubung ke server. Periksa koneksi/URL server kamu.');
    }
  }
}