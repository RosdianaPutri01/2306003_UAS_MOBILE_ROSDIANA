import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/admin_provider.dart';
import '../../utils/currency_formatter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      admin.loadStats();
      admin.loadTopProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await admin.loadStats();
        await admin.loadTopProducts();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Statistik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _buildStatsGrid(admin),
          const SizedBox(height: 28),
          const Text('Produk Terlaris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _buildTopProductsChart(admin),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AdminProvider admin) {
    if (admin.isLoadingStats) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
    if (admin.statsError != null) {
      return Center(
        child: Column(
          children: [
            Text(admin.statsError!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: admin.loadStats, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    final stats = admin.stats;
    if (stats == null) return const SizedBox();

    final cards = [
      _StatCardData('Total Produk', '${stats.totalProducts}', Icons.inventory_2_outlined, Colors.indigo),
      _StatCardData('Total Pesanan', '${stats.totalOrders}', Icons.receipt_long_outlined, Colors.teal),
      _StatCardData('Total Pendapatan', formatRupiah(stats.totalRevenue), Icons.payments_outlined, Colors.green),
      _StatCardData('Total Pelanggan', '${stats.totalCustomers}', Icons.people_outline, Colors.orange),
      _StatCardData('Pesanan Pending', '${stats.pendingOrders}', Icons.pending_actions_outlined, Colors.red),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _statCard(cards[index]),
    );
  }

  Widget _statCard(_StatCardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.color),
          const Spacer(),
          Text(data.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(data.label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopProductsChart(AdminProvider admin) {
    if (admin.isLoadingTopProducts) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
    if (admin.topProducts.isEmpty) {
      return const Text('Belum ada data penjualan.', style: TextStyle(color: Colors.grey));
    }

    final top5 = admin.topProducts.take(5).toList();
    final maxSold = top5.map((e) => e.totalSold).reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxSold * 1.2,
          barGroups: List.generate(top5.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: top5[index].totalSold.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= top5.length) {
                    return const SizedBox();
                  }
                  final name = top5[index].name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name.length > 8 ? '${name.substring(0, 8)}..' : name,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatCardData(this.label, this.value, this.icon, this.color);
}