import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_firebase/features/posts/domain/models/post_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new post
  Future<void> createPost({
    required String content,
    required String familyId,
    List<String>? imageUrls,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final postRef = _firestore.collection('posts').doc();
    
    final post = PostModel(
      id: postRef.id,
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous',
      userImageUrl: user.photoURL,
      content: content,
      imageUrls: imageUrls,
      familyId: familyId,
      createdAt: DateTime.now(),
    );

    await postRef.set(post.toJson());
  }

  // Get posts from user's family members
  Stream<List<PostModel>> getFamilyPosts(String familyId) {
    return _firestore
        .collection('posts')
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromJson({...doc.data() as Map, 'id': doc.id}))
          .toList();
    });
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;
      
      final post = PostModel.fromJson(postDoc.data() as Map<String, dynamic>);
      final isLiked = post.likedBy.contains(userId);
      
      if (isLiked) {
        // Unlike
        transaction.update(postRef, {
          'likedBy': FieldValue.arrayRemove([userId]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        transaction.update(postRef, {
          'likedBy': FieldValue.arrayUnion([userId]),
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  // Add a comment to a post
  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    await commentRef.set({
      'id': commentRef.id,
      'postId': postId,
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'userImageUrl': user.photoURL,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }
}
