import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/exception.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/features/family/data/models/family_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FamilyRemoteDataSource {
  Future<FamilyModel> createFamily(String familyName, String createdBy);
  Future<FamilyModel> joinFamily(String inviteCode, String userId);
  Future<FamilyModel?> getCurrentFamily(String userId);
  Future<bool> validateInviteCode(String inviteCode);
  Future<String> generateNewInviteCode(String familyId);
}

class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FamilyRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<FamilyModel> createFamily(String familyName, String createdBy) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null || currentUser.uid != createdBy) {
        throw const ServerException('User not authenticated');
      }

      // Check if user is already in a family
      final userDoc = await firestore.collection('users').doc(createdBy).get();
      if (userDoc.exists && userDoc.data()?['familyId'] != null) {
        throw const ServerException('User already in a family');
      }

      // Generate a unique family ID
      final familyRef = firestore.collection('families').doc();
      
      // Generate initial invite code
      final inviteCode = await _generateUniqueInviteCode();
      
      // Create family data
      final familyData = {
        'id': familyRef.id,
        'name': familyName,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'memberIds': [createdBy],
        'memberJoinDates': {
          createdBy: FieldValue.serverTimestamp(),
        },
        'currentInviteCode': inviteCode,
        'inviteCodeExpiresAt': _getInviteCodeExpiry(),
        'inviteCodesHistory': [inviteCode],
      };

      // Start a batch write to ensure data consistency
      final batch = firestore.batch();
      
      // Create family document
      batch.set(familyRef, familyData);
      
      // Update user document with family ID
      batch.set(
        firestore.collection('users').doc(createdBy),
        {'familyId': familyRef.id},
        SetOptions(merge: true),
      );
      
      // Commit the batch
      await batch.commit();

      return FamilyModel.fromJson(familyData);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create family');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<FamilyModel> joinFamily(String inviteCode, String userId) async {
    try {
      // Find family with the given invite code
      final querySnapshot = await firestore
          .collection('families')
          .where('currentInviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw const ServerException('Invalid or expired invite code');
      }

      final familyDoc = querySnapshot.docs.first;
      final familyData = familyDoc.data();
      final familyId = familyDoc.id;
      
      // Check if invite code is expired
      final expiryTimestamp = familyData['inviteCodeExpiresAt'] as Timestamp?;
      if (expiryTimestamp == null || expiryTimestamp.toDate().isBefore(DateTime.now())) {
        throw const ServerException('Invite code has expired');
      }
      
      // Check if user is already in this family
      final memberIds = List<String>.from(familyData['memberIds'] ?? []);
      if (memberIds.contains(userId)) {
        throw const ServerException('You are already a member of this family');
      }
      
      // Start a batch write to ensure data consistency
      final batch = firestore.batch();
      
      // Update family document to add the new member
      batch.update(familyDoc.reference, {
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberJoinDates.${userId}': FieldValue.serverTimestamp(),
      });
      
      // Update user document with family ID
      batch.set(
        firestore.collection('users').doc(userId),
        {'familyId': familyId},
        SetOptions(merge: true),
      );
      
      // Commit the batch
      await batch.commit();
      
      // Return the updated family data
      return FamilyModel.fromJson({
        ...familyData,
        'id': familyId,
        'memberIds': [...memberIds, userId],
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to join family');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<FamilyModel?> getCurrentFamily(String userId) async {
    try {
      // Get user document to find family ID
      final userDoc = await firestore.collection('users').doc(userId).get();
      final familyId = userDoc.data()?['familyId'] as String?;
      
      if (familyId == null) return null;
      
      // Get family document
      final familyDoc = await firestore.collection('families').doc(familyId).get();
      if (!familyDoc.exists) return null;
      
      return FamilyModel.fromJson({
        ...?familyDoc.data(),
        'id': familyDoc.id,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get family');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<bool> validateInviteCode(String inviteCode) async {
    try {
      final querySnapshot = await firestore
          .collection('families')
          .where('currentInviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;
      
      final familyData = querySnapshot.docs.first.data();
      final expiryTimestamp = familyData['inviteCodeExpiresAt'] as Timestamp?;
      
      // Check if invite code is expired
      return expiryTimestamp != null && expiryTimestamp.toDate().isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> generateNewInviteCode(String familyId) async {
    try {
      final newCode = await _generateUniqueInviteCode();
      
      await firestore.collection('families').doc(familyId).update({
        'currentInviteCode': newCode,
        'inviteCodeExpiresAt': _getInviteCodeExpiry(),
        'inviteCodesHistory': FieldValue.arrayUnion([newCode]),
      });
      
      return newCode;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to generate invite code');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
  
  // Helper method to generate a unique invite code
  Future<String> _generateUniqueInviteCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code;
    bool isUnique = false;
    
    // Try up to 5 times to generate a unique code
    for (int i = 0; i < 5 && !isUnique; i++) {
      // Generate a random 8-character code
      code = String.fromCharCodes(
        Iterable.generate(8, (index) => chars.codeUnitAt((random + index + i) % chars.length)),
      );
      
      // Check if code is already in use
      final querySnapshot = await firestore
          .collection('families')
          .where('currentInviteCode', isEqualTo: code)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return code;
      }
    }
    
    // If we couldn't find a unique code after several attempts
    throw const ServerException('Failed to generate a unique invite code');
  }
  
  // Helper method to get the expiry date for an invite code (7 days from now)
  DateTime _getInviteCodeExpiry() {
    return DateTime.now().add(const Duration(days: 7));
  }
}
