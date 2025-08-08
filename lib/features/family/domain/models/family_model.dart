class FamilyModel {
  final String id;
  final String name;
  final String inviteCode;
  final String adminId;
  final String? familyPhotoUrl;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminId,
    this.familyPhotoUrl,
    List<String>? memberIds,
    required this.createdAt,
    required this.updatedAt,
  }) : memberIds = memberIds ?? [];

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'adminId': adminId,
      'familyPhotoUrl': familyPhotoUrl,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create model from JSON
  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'],
      name: json['name'],
      inviteCode: json['inviteCode'],
      adminId: json['adminId'],
      familyPhotoUrl: json['familyPhotoUrl'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
