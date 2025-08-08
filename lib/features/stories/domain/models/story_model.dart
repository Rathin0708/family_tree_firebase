import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String? imageUrl;
  final String? text;
  final String? videoUrl;
  final String? location;
  final List<String> viewers; // User IDs who viewed the story
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    this.imageUrl,
    this.text,
    this.videoUrl,
    this.location,
    List<String>? viewers,
    required this.createdAt,
    required this.expiresAt,
  }) : viewers = viewers ?? [];

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'imageUrl': imageUrl,
      'text': text,
      'videoUrl': videoUrl,
      'location': location,
      'viewers': viewers,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  // Create model from JSON
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userImageUrl: json['userImageUrl'],
      imageUrl: json['imageUrl'],
      text: json['text'],
      videoUrl: json['videoUrl'],
      location: json['location'],
      viewers: List<String>.from(json['viewers'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: (json['expiresAt'] as Timestamp).toDate(),
    );
  }
}
