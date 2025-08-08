class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? profileImageUrl;
  final String? familyId;
  final String? familyName;
  final String? familyRole; // 'admin', 'member', etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.profileImageUrl,
    this.familyId,
    this.familyName,
    this.familyRole,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'familyId': familyId,
      'familyName': familyName,
      'familyRole': familyRole,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      familyId: json['familyId'],
      familyName: json['familyName'],
      familyRole: json['familyRole'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
