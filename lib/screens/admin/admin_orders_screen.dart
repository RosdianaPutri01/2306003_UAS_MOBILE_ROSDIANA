import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/admin_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/order_status.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAdminOrders();
    });
  }

  Future<void> _changeStatus(
      BuildContext context, String orderId, String currentStatus) async {
    final admin = context.read<AdminProvider>();

    final newStatus = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Ubah Status Pesanan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final status in [...kOrderStatusFlow, 'cancelled'])
              ListTile(
                title: Text(getOrderStatusInfo(status).label),
                enabled: isValidStatusTransition(currentStatus, status),
                trailing: status == currentStatus
                    ? const Icon(Icons.check, color: Colors.indigo)
                    : null,
                onTap: isValidStatusTransition(currentStatus, status)
                    ? () => Navigator.pop(ctx, status)
                    : null,
              ),
          ],
        ),
      ),
    );

    if (newStatus == null || !context.mounted) return;

    final success = await admin.updateOrderStatus(orderId, newStatus);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Status berhasil diubah'
            : (admin.ordersError ?? 'Gagal mengubah status')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Semua'),
                  selected: admin.statusFilter == null,
                  onSelected: (_) => admin.setStatusFilter(null),
                ),
              ),
              for (final status in [...kOrderStatusFlow, 'cancelled'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(getOrderStatusInfo(status).label),
                    selected: admin.statusFilter == status,
                    onSelected: (_) => admin.setStatusFilter(status),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _buildOrderList(admin)),
      ],
    );
  }

  Widget _buildOrderList(AdminProvider admin) {
    if (admin.isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    if (admin.ordersError != null && admin.adminOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(admin.ordersError!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: admin.loadAdminOrders,
                child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    if (admin.adminOrders.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan'));
    }

    return RefreshIndicator(
      onRefresh: admin.loadAdminOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: admin.adminOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = admin.adminOrders[index];
          final statusInfo = getOrderStatusInfo(order.status);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('#${order.shortOrderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(statusInfo.label,
                          style: TextStyle(
                              color: statusInfo.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ],
                ),
                if (order.customerName != null) ...[
                  const SizedBox(height: 4),
                  Text('Pelanggan: ${order.customerName}',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                ],
                if (order.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt!),
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
                const SizedBox(height: 8),
                Text(formatRupiah(order.totalAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: (order.status == 'delivered' ||
                            order.status == 'cancelled')
                        ? null
                        : () => _changeStatus(context, order.id, order.status),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Ubah Status'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
