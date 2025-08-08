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
    // Ensure user document exists before proceeding
    await _ensureUserDocumentExists(userId);
    
    // Find family by invite code
    final query = await _firestore
        .collection('families')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final familyDoc = query.docs.first;
    final family = FamilyModel.fromJson(familyDoc.data()..['id'] = familyDoc.id);

    // Start a batch write
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // Add user to family members
    final familyRef = _firestore.collection('families').doc(family.id);
    batch.update(familyRef, {
      'memberIds': FieldValue.arrayUnion([userId]),
      'updatedAt': now,
    });

    // Update user's family info using set with merge to ensure document exists
    final userRef = _firestore.collection('users').doc(userId);
    batch.set(userRef, {
      'familyId': family.id,
      'familyName': family.name,
      'familyRole': 'member',
      'updatedAt': now,
    }, SetOptions(merge: true));

    // Add a notification to the family
    final notificationRef = _firestore
        .collection('families')
        .doc(family.id)
        .collection('notifications')
        .doc();
    
    batch.set(notificationRef, {
      'type': 'member_joined',
      'userId': userId,
      'userName': userName,
      'message': '$userName has joined the family',
      'isRead': false,
      'createdAt': now,
    });

    // Commit the batch
    await batch.commit();
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

  // Generate a random 8-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt((chars.length * DateTime.now().millisecond) % chars.length),
      ),
    );
  }
}
