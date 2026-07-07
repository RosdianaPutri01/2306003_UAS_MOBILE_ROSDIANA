/// Model ini cuma "cetakan" bentuk data user. Tidak ada logika API di sini.
class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.role,
  });

  /// Helper: ambil nilai jadi String dengan aman, apapun bentuk aslinya
  /// (String biasa, atau object/Map seperti { "id": 2, "name": "admin" }).
  static String? _toSafeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      // Kalau berupa object, coba ambil field umum: name / role_name / label
      return (value['name'] ?? value['role_name'] ?? value['label'])?.toString();
    }
    return value.toString();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Supabase Auth kadang menaruh profil di dalam key "user".
    final data = json['user'] ?? json;

    return User(
      id: (data['id'] ?? '').toString(),
      fullName: _toSafeString(data['full_name'] ?? data['fullName'] ?? data['name']) ?? '',
      email: _toSafeString(data['email']) ?? '',
      phoneNumber: _toSafeString(data['phone_number'] ?? data['phoneNumber'] ?? data['phone']),
      role: _toSafeString(data['role']),
    );
  }
}