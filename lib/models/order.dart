class OrderItem {
  final String productName;
  final int quantity;
  final num price;

  OrderItem({required this.productName, required this.quantity, required this.price});

  num get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // NOTE: mengikuti pola nested "products"/"categories" sebelumnya.
    final productData = json['products'] ?? json['product'] ?? {};
    return OrderItem(
      productName: productData['name'] ?? json['product_name'] ?? 'Produk',
      quantity: json['quantity'] ?? 1,
      price: json['price'] ?? productData['price'] ?? 0,
    );
  }
}

class Order {
  final String id;
  final num totalAmount;
  final String status; // pending | processing | shipped | delivered | cancelled
  final String shippingAddress;
  final String? notes;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final String? customerName; // dipakai di admin order list

  Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.notes,
    this.createdAt,
    this.items = const [],
    this.customerName,
  });

  /// Nomor pesanan yang ditampilkan ke user: 8 karakter pertama UUID
  String get shortOrderNumber => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory Order.fromJson(Map<String, dynamic> json) {
    // NOTE: cek nama field asli di Swagger kamu, kemungkinan "total_amount"
    // atau "total_price" atau "grand_total" -- sesuaikan kalau beda.
    final total = json['total_amount'] ?? json['total_price'] ?? json['grand_total'] ?? 0;

    final rawItems = json['order_items'] ?? json['items'] ?? [];
    final userData = json['users'] ?? json['user'];

    return Order(
      id: (json['id'] ?? '').toString(),
      totalAmount: total,
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      shippingAddress: json['shipping_address'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      items: (rawItems as List).map((e) => OrderItem.fromJson(e)).toList(),
      customerName: userData is Map ? userData['full_name'] : null,
    );
  }
}