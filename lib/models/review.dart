class Review {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Backend membalas nama pengulas di dalam key "reviewer": { id, full_name, avatar_url }
    // TAPI nilainya bisa "null" (bukan cuma nama field beda), jadi harus dicek
    // dulu tipe datanya sebelum diakses -- ini yang kemarin bikin parsing crash diam-diam.
    final rawReviewer = json['reviewer'] ?? json['users'] ?? json['user'];
    final Map? reviewerMap = rawReviewer is Map ? rawReviewer : null;

    return Review(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? reviewerMap?['id'] ?? '').toString(),
      userName: reviewerMap?['full_name']?.toString() ?? 'Pengguna',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}