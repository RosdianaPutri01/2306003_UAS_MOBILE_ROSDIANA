import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Kumpulan konstanta API.
class ApiConstants {
  static const String _physicalDeviceUrl = 'http://192.168.100.11:3000/api';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      return _physicalDeviceUrl;
    }
    return 'http://localhost:3000/api';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Categories & Products (Soal 2)
  static const String categories = '/categories';
  static const String products = '/products';

  // Cart (Soal 3)
  static const String cart = '/cart';

  // Orders (Soal 4)
  static const String orders = '/orders';

  // Reviews (Soal 2)
  static const String reviews = '/reviews';

  // Dashboard (Soal 5)
  static const String dashboard = '/dashboard';
}
