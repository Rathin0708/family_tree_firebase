import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:family_tree_firebase/features/stories/domain/models/story_model.dart';
import 'dart:io';

// Initialize Firebase Storage
final FirebaseStorage storage = FirebaseStorage.instance;

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload a new story
  Future<StoryModel> uploadStory({
    required String userId,
    required String userName,
    String? userImageUrl,
    File? imageFile,
    File? videoFile,
    String? text,
    String? location,
  }) async {
    String? imageUrl;
    String? videoUrl;

    // Upload image if exists
    if (imageFile != null) {
      imageUrl = await _uploadFile(
        file: imageFile,
        path: 'stories/$userId/images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    // Upload video if exists
    if (videoFile != null) {
      videoUrl = await _uploadFile(
        file: videoFile,
        path: 'stories/$userId/videos/${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
    }

    final now = DateTime.now();
    final story = StoryModel(
      id: _firestore.collection('stories').doc().id,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      text: text,
      location: location,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)), // Stories expire after 24 hours
    );

    await _firestore
        .collection('stories')
        .doc(story.id)
        .set(story.toJson());

    return story;
  }

  // Get stories for a family
  Stream<List<StoryModel>> getFamilyStories(String familyId) {
    return _firestore
        .collection('stories')
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoryModel.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  // Mark story as viewed
  Future<void> markAsViewed(String storyId, String userId) async {
    await _firestore.collection('stories').doc(storyId).update({
      'viewers': FieldValue.arrayUnion([userId]),
    });
  }

  // Delete a story
  Future<void> deleteStory(String storyId) async {
    await _firestore.collection('stories').doc(storyId).delete();
  }

  // Helper method to upload files to Firebase Storage
  Future<String> _uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final ref = storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }
}
