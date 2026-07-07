class CartItem {
  final String id;         // id baris cart (dipakai untuk PUT/DELETE /cart/:id)
  final String productId;
  final String productName;
  final String? productImageUrl;
  final num price;
  final int quantity;
  final int stock;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.stock,
  });

  num get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // NOTE: mengikuti pola nested "categories" pada produk, kemungkinan besar
    // cart item punya nested key "products". Cek Swagger GET /cart punya kamu,
    // sesuaikan key di bawah kalau berbeda (misal "product" tunggal).
    final productData = json['products'] ?? json['product'] ?? {};

    return CartItem(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? productData['id'] ?? '').toString(),
      productName: productData['name'] ?? 'Produk',
      productImageUrl: productData['image_url'],
      price: json['price'] ?? productData['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      stock: productData['stock'] ?? 0,
    );
  }
}