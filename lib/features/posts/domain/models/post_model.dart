class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String content;
  final List<String>? imageUrls;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;
  final String familyId;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.content,
    this.imageUrls,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    List<String>? likedBy,
    required this.familyId,
  }) : likedBy = likedBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
      'familyId': familyId,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userImageUrl: json['userImageUrl'],
      content: json['content'],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      likedBy: json['likedBy'] != null ? List<String>.from(json['likedBy']) : [],
      familyId: json['familyId'] ?? '',
    );
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    List<String>? likedBy,
    String? familyId,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedBy: likedBy ?? this.likedBy,
      familyId: familyId ?? this.familyId,
    );
  }
}
