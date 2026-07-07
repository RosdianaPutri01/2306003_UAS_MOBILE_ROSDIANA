import 'package:flutter/material.dart';

class OrderStatusInfo {
  final String label;
  final Color color;
  const OrderStatusInfo(this.label, this.color);
}

/// Satu tempat untuk mapping status -> warna & label.
/// Dipakai di riwayat pesanan & detail pesanan supaya konsisten.
OrderStatusInfo getOrderStatusInfo(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const OrderStatusInfo('Pending', Colors.orange);
    case 'processing':
      return const OrderStatusInfo('Diproses', Colors.blue);
    case 'shipped':
      return const OrderStatusInfo('Dikirim', Colors.purple);
    case 'delivered':
      return const OrderStatusInfo('Selesai', Colors.green);
    case 'cancelled':
      return const OrderStatusInfo('Dibatalkan', Colors.red);
    default:
      return OrderStatusInfo(status, Colors.grey);
  }
}