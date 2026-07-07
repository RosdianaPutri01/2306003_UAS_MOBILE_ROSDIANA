class DashboardStats {
  final int totalProducts;
  final int totalOrders;
  final num totalRevenue;
  final int totalCustomers;
  final int pendingOrders;

  DashboardStats({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCustomers,
    required this.pendingOrders,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Dikonfirmasi dari dashboard.controller.js:
    // { total_products, total_orders, total_users, total_revenue, orders_by_status: {...} }
    final ordersByStatus = json['orders_by_status'] as Map<String, dynamic>?;

    return DashboardStats(
      totalProducts: json['total_products'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      totalCustomers: json['total_users'] ?? 0,
      pendingOrders: ordersByStatus?['pending'] ?? 0,
    );
  }
}

class TopProduct {
  final String name;
  final int totalSold;

  TopProduct({required this.name, required this.totalSold});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    // Dikonfirmasi dari dashboard.controller.js: field-nya rata (flat),
    // bukan nested "products"/"product".
    return TopProduct(
      name: json['product_name'] ?? 'Produk',
      totalSold: json['total_sold'] ?? 0,
    );
  }
}