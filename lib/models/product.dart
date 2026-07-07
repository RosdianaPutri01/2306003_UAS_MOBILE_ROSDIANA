import 'category.dart';

class Product {
  final String id;
  final String name;
  final String slug;
  final String description;
  final num price;
  final int stock;
  final String categoryId;
  final String? imageUrl;
  final bool isActive;
  final Category? category;
  final double? avgRating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
    this.isActive = true,
    this.category,
    this.avgRating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      categoryId: (json['category_id'] ?? '').toString(),
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      // NOTE: nested key dari Swagger namanya "categories" (jamak), bukan "category"
      category: json['categories'] != null ? Category.fromJson(json['categories']) : null,
      // NOTE: cek Swagger detail produk (GET /products/:id) untuk nama field rating asli,
      // kemungkinan "average_rating" atau "rating_avg" -- sesuaikan kalau beda.
      avgRating: (json['average_rating'] ?? json['avg_rating'])?.toDouble(),
      reviewCount: json['review_count'],
    );
  }
}