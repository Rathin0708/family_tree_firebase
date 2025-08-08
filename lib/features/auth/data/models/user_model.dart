class UserModel {
  final String? id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
