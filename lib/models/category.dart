class Category {
  final String id;
  final String name;
  final String slug;

  Category({required this.id, required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}