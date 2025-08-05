import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';

abstract class FamilyRepository {
  /// Creates a new family with the given name and returns the generated invite code
  Future<Either<Failure, String>> createFamily(String familyName);
  
  /// Joins a family using the provided invite code
  Future<Either<Failure, Family>> joinFamily(String inviteCode);
  
  /// Gets the current user's family if they are part of one
  Future<Either<Failure, Family?>> getCurrentFamily();
  
  /// Validates if an invite code is valid and not expired
  Future<Either<Failure, bool>> validateInviteCode(String inviteCode);
  
  /// Generates a new invite code for the current user's family
  Future<Either<Failure, String>> generateNewInviteCode();
}
