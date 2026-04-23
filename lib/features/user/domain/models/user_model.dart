class UserModel {
  final String id;
  final String name;
  final String email;
  final String? currency;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.currency,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      currency: json['currency'],
      createdAt: json['created_at'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? currency,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}