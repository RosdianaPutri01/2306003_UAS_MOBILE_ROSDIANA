import 'package:intl/intl.dart';

/// Helper kecil, dipakai di manapun butuh format harga.
/// Contoh: formatRupiah(8500000) -> "Rp 8.500.000"
String formatRupiah(num value) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(value);
}