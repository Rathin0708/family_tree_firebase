import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tree_firebase/features/family/domain/models/family_model.dart';
import 'package:family_tree_firebase/features/auth/domain/models/user_model.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to ensure user document exists
  Future<void> _ensureUserDocumentExists(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      // Create a basic user document if it doesn't exist
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': 'New User', // This will be updated when user updates their profile
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Create a new family
  Future<FamilyModel> createFamily({
    required String name,
    required String adminId,
  }) async {
    // Ensure user document exists before proceeding
    await _ensureUserDocumentExists(adminId);
    
    final familyRef = _firestore.collection('families').doc();
    final inviteCode = _generateInviteCode();
    final now = DateTime.now();

    final family = FamilyModel(
      id: familyRef.id,
      name: name,
      inviteCode: inviteCode,
      adminId: adminId,
      memberIds: [adminId],
      createdAt: now,
      updatedAt: now,
    );

    // Start a batch write
    final batch = _firestore.batch();

    // Add family to families collection
    batch.set(familyRef, family.toJson());

    // Update user's family info
    final userRef = _firestore.collection('users').doc(adminId);
    
    // Use set with merge: true to create or update the document
    batch.set(userRef, {
      'familyId': family.id,
      'familyName': family.name,
      'familyRole': 'admin',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    try {
      // Commit the batch
      await batch.commit();
      return family;
    } catch (e) {
      // If batch commit fails, try to clean up the family document
      await familyRef.delete().catchError((_) {});
      rethrow;
    }
  }

  // Join a family using invite code
  Future<void> joinFamily({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    // Start a transaction to ensure data consistency
    await _firestore.runTransaction((transaction) async {
      // 1. Validate inputs
      if (inviteCode.trim().isEmpty) {
        throw Exception('Invite code cannot be empty');
      }
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      // 2. Get user document
      final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
      
      // 3. Check if user is already in a family
      if (userDoc.exists && userDoc.data()?['familyId'] != null) {
        throw Exception('You are already a member of another family');
      }
      
      // 4. Find family by invite code (case-insensitive search)
      final familyQuery = await _firestore
          .collection('families')
          .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (familyQuery.docs.isEmpty) {
        throw Exception('Invalid invite code. Please check and try again.');
      }

      final familyDoc = familyQuery.docs.first;
      final familyData = familyDoc.data()..['id'] = familyDoc.id;
      final family = FamilyModel.fromJson(familyData);

      // 5. Check if user is already a member of this family
      if (family.memberIds.contains(userId)) {
        throw Exception('You are already a member of this family');
      }

      final now = DateTime.now();
      final familyRef = _firestore.collection('families').doc(family.id);
      final userRef = _firestore.collection('users').doc(userId);

      // 6. Update family document - add user to members
      transaction.update(familyRef, {
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': now.toIso8601String(),
      });

      // 7. Update user document with family info
      transaction.set(userRef, {
        'familyId': family.id,
        'familyName': family.name,
        'familyRole': 'member',
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));

      // 8. Add a welcome notification
      final notificationRef = _firestore
          .collection('families')
          .doc(family.id)
          .collection('notifications')
          .doc();
      
      transaction.set(notificationRef, {
        'type': 'member_joined',
        'userId': userId,
        'userName': userName,
        'message': '$userName has joined the family',
        'isRead': false,
        'createdAt': now.toIso8601String(),
      });

      // 9. Ensure user document exists with basic info if it's a new user
      if (!userDoc.exists) {
        transaction.set(userRef, {
          'id': userId,
          'name': userName,
          'email': userDoc.data()?['email'] ?? '',
          'photoUrl': userDoc.data()?['photoUrl'] ?? '',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }, SetOptions(merge: true));
      }
    }).timeout(const Duration(seconds: 30), onTimeout: () {
      throw Exception('Request timed out. Please try again.');
    });
  }

  // Get family by ID
  Future<FamilyModel> getFamily(String familyId) async {
    final doc = await _firestore.collection('families').doc(familyId).get();
    if (!doc.exists) {
      throw Exception('Family not found');
    }
    return FamilyModel.fromJson(doc.data()!..['id'] = doc.id);
  }

  // Get family members
  Future<List<UserModel>> getFamilyMembers(String familyId) async {
    final query = await _firestore
        .collection('users')
        .where('familyId', isEqualTo: familyId)
        .get();

    return query.docs
        .map((doc) => UserModel.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  // Generate a unique 8-character invite code
  String _generateInviteCode() {
    // Remove similar looking characters (0/O, 1/I) to avoid confusion
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code = StringBuffer();
    
    // Generate a 6-character code (can be adjusted as needed)
    for (var i = 0; i < 6; i++) {
      code.write(chars[random.nextInt(chars.length)]);
    }
    
    // Add a checksum character to help validate the code
    final checkSum = code.toString().codeUnits.fold(0, (sum, char) => sum + char) % chars.length;
    code.write(chars[checkSum]);
    
    // Add a random character at the end
    code.write(chars[random.nextInt(chars.length)]);
    
    // Shuffle the characters to make it less predictable
    final codeList = code.toString().split('')..shuffle(random);
    return codeList.join().toUpperCase();
  }
}
