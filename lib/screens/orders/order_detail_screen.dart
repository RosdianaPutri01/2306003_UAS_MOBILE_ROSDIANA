import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/order_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/order_status.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.selectedOrder;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: provider.isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Text('#${order.shortOrderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Spacer(),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    if (order.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt!),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                    const Divider(height: 32),

                    const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(order.shippingAddress.isEmpty ? '-' : order.shippingAddress),
                    const SizedBox(height: 16),

                    const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(order.notes == null || order.notes!.isEmpty ? '-' : order.notes!),
                    const Divider(height: 32),

                    const Text('Item Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('${item.quantity} x ${formatRupiah(item.price)}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                    const Divider(height: 32),

                    Row(
                      children: [
                        const Text('Total Keseluruhan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Text(
                          formatRupiah(order.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final info = getOrderStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: info.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: info.color),
          const SizedBox(width: 6),
          Text(info.label, style: TextStyle(color: info.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}